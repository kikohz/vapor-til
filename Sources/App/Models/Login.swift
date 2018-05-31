import Vapor
import FluentMySQL

struct LoginRequest: Codable {
    var id: Int?
    var email: String
    var password: String
    
    init(email:String, password:String) {
        self.email = email;
        self.password  = password
    }
}

extension LoginRequest: MySQLModel {}

//要吧model保存到数据库中，需要创建一个表，Fluent 通过 Migration 来完成这个操作
extension LoginRequest: Migration {}

extension LoginRequest: Content {}

extension LoginRequest: Parameter {}
