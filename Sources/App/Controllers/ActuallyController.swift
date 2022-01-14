import Fluent
import Vapor

struct ActuallyController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let actuallys = routes.grouped("actuallys")
        actuallys.get(use: index)
        actuallys.post(use: create)
        actuallys.group(":actuallyID") { actually in
            actually.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[Actually]> {
        return Actually.query(on: req.db).all()
    }

    func create(req: Request) throws -> EventLoopFuture<Actually> {
        let actually = try req.content.decode(Actually.self)
        return actually.save(on: req.db).map { actually }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Actually.find(req.parameters.get("actuallyID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
