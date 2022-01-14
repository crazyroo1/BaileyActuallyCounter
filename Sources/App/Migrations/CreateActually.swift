import Fluent

struct CreateActually: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("actuallys")
            .id()
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("actuallys").delete()
    }
}
