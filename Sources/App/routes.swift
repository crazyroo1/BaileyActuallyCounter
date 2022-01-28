import Fluent
import Vapor

func routes(_ app: Application) throws {
    let clients = WebsocketClients(eventLoop: app.eventLoopGroup.any())
    
    func getStatisticalData(_ req: Request) -> EventLoopFuture<ActuallyGroup> {
        Actually
            .query(on: req.db)
            .sort(\.$createdAt)
            .all()
            .map { actuallys in
                let total = actuallys.count
                
                let days = actuallys
                    .sliced(by: [.year, .month, .day], for: \.createdAt)
                    .sorted { $0.key < $1.key }
                
                let average: Int = {
                    guard !days.isEmpty else { return 0 }
                    
                    let filteredDays = days.filter { $0.value.count > 50 }
                    var n = 0
                    for day in filteredDays {
                        n += day.value.count
                    }
                    return n / filteredDays.count
                }()
                
                let amountPerDay: [ActuallyGroup.AmountPerDayData] = days
                    .enumerated()
                    .map { day in
                        let averageSecondsBetween: Int = {
                            let sortedActuallys = day.element.value.sorted { lhs, rhs in lhs.createdAt! < rhs.createdAt! }
                            
                            var totalSeconds = 0
                            guard sortedActuallys.count >= 2 else { return 0 }
                            for i in 0 ... sortedActuallys.count - 2 {
                                let first = sortedActuallys[i].createdAt!
                                let second = sortedActuallys[i+1].createdAt!
                                totalSeconds += Int(second.timeIntervalSince(first) + 0.5)
                            }
                            return totalSeconds / (sortedActuallys.count - 1)
                        }()
                        return .init(classNumber: day.offset + 3,
                                     amount: day.element.value.count,
                                     averageSecondsBetween: averageSecondsBetween)
                    }
                    .reversed()
                
                
                let data = ActuallyGroup(sortedList: actuallys,
                                         total: total,
                                         average: average,
                                         amountPerDay: amountPerDay)
                
                
                return data
            }
    }
    
    app.get { req -> EventLoopFuture<View> in
        getStatisticalData(req)
            .flatMap { data in
                req.view.render("index", ["data": data])
            }
    }
    
    app.get("statistics") { req -> EventLoopFuture<View> in
        getStatisticalData(req)
            .flatMap { data in
                req.view.render("statistics", ["data": data])
            }
    }
    
    app.get("number") { req -> EventLoopFuture<Int> in
        Actually
            .query(on: req.db)
            .all()
            .map { actuallys in
                actuallys.count
            }
    }
    
    app.post("newactually") { req -> EventLoopFuture<HTTPStatus> in
        Actually()
            .save(on: req.db)
            .map {
                clients.storage.forEach { client in
                    client.socket.send("newactually", promise: nil)
                }
            }
            .transform(to: .ok)
    }
    
    app.delete("latest") { req -> EventLoopFuture<HTTPStatus> in
        Actually
            .query(on: req.db)
            .sort(\.$createdAt, .descending)
            .first()
            .unwrap(or: Abort(.internalServerError))
            .flatMap { actually in
                actually
                    .delete(on: req.db)
                    .map {
                        clients.storage.forEach { client in
                            client.socket.send("newactually", promise: nil)
                        }
                    }
                    .transform(to: .ok)
            }
            
    }
    
    app.webSocket("socket") { req, socket in
        clients.add(WebSocketClient(socket: socket))
        
        socket.onText { socket, message in
            if message == "number" {
                _ = Actually
                    .query(on: req.db)
                    .all()
                    .map { actuallys in
                        socket.send("\(actuallys.count)")
                    }
            }
        }
    }
}


extension Array {
    func sliced(by dateComponents: Set<Calendar.Component>, for key: KeyPath<Element, Date?>) -> [Date: [Element]] {
        let initial: [Date: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur[keyPath: key]!)
            let date = Calendar.current.date(from: components)!
            acc[date, default: []] += [cur]
        }
        
        return groupedByDateComponents
    }
}
