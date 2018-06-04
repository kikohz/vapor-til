import Vapor
import FluentMySQL

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    var userID:User.ID
    
    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

extension Acronym {
    var user: Parent<Acronym,User> {
        return parent(\.userID)
    }
}

extension Acronym: MySQLModel {}

//要吧model保存到数据库中，需要创建一个表，Fluent 通过 Migration 来完成这个操作
extension Acronym: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            try builder.addReference(from: \.userID, to: \User.id)
        }
    }
}

extension Acronym: Content {}

extension Acronym: Parameter {}






