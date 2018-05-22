import Vapor
import FluentSQLite

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}

extension Acronym :Model {
    //使用寿命数据库
    typealias Database = SQLiteDatabase
    //id的类型
    typealias ID = Int
    //设置 ID 属性的路径
    public static var idKey: IDKey = \Acronym.id
}

extension Acronym: SQLiteModel {}

//要吧model保存到数据库中，需要创建一个表，Fluent 通过 Migration 来完成这个操作
extension Acronym: Migration {}

extension Acronym: Content {}
