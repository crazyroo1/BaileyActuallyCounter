import Fluent
import Vapor

final class Actually: Model, Content {
    static let schema = "actuallys"
    
    @ID(key: .id)
    var id: UUID?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil) {
        self.id = id
        self.createdAt = nil
    }
}
