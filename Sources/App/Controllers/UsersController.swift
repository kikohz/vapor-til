import Vapor
import Fluent

struct UsersController: RouteCollection {
    //注册
    func boot(router: Router) throws {
        let userRoute = router.grouped("api","users")
        userRoute.post(User.self, use: creatHandler)
        userRoute.get( use: getAllHandler)
        userRoute.get(User.parameter, use: getHandle)
        userRoute.get(User.parameter, use: getAcronymsHandler)
    }
    
    func creatHandler(_ req:Request,user:User) throws -> Future<User> {
        return user.save(on: req)
    }
    
    func getAllHandler(_ req:Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getHandle(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
    func getAcronymsHandler(_ req: Request) throws ->Future<[Acronym]> {
        return try req.parameters.next(User.self).flatMap(to: [Acronym].self) {user in
            try user.acronyms.query(on: req).all()
        }
    }
}
