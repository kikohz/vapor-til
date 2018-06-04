import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        let acronymsRoutes = router.grouped("api","acronyms")
        router.get("api", "acronyms", use: getAllHandler)
//        acronymsRoutes.post(use: creatAcronym)
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        acronymsRoutes.put(Acronym.parameter, use: updateHandler)
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
        //
        acronymsRoutes.post(Acronym.self, use: creatHandle)
        
        acronymsRoutes.get(Acronym.parameter,"user", use: getUserHandler)
    }
    
    //创建
    func creatAcronym(_ req: Request) throws -> Future<Acronym> {
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            return acronym.save(on: req)
        }
    }
    
    func creatHandle(_ req: Request,acronym:Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    //获取
    func getHandler(_ req:Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    //更新
    func updateHandler(_ req:Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)) { acronym, updatedAcronym in
                            acronym.short = updatedAcronym.short
                            acronym.long = updatedAcronym.long
                            acronym.userID = updatedAcronym.userID
                            return acronym.save(on: req)
        }
    }
    //获取所有
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    //删除
    func deleteHandler(_ req:Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self).flatMap(to: HTTPStatus.self) { acronym in
            acronym.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    //搜索
    func searchHandler(_ req:Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at:"term"] else {
            throw Abort(.badRequest)
        }
        return try Acronym.query(on:req).group(.or) {or in
            try or.filter(\.short == searchTerm)
            try or.filter(\.long == searchTerm)
        }.all()
    }
    
    //第一个
    func getFirstHandler(_ req:Request) throws -> Future<Acronym> {
        return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
            guard let temacronym = acronym else {
                throw Abort(.notFound)
            }
            return temacronym
        }
    }
    //排序
    func sortedHandler(_ req:Request) throws-> Future<[Acronym]> {
        return try Acronym.query(on: req).sort(\.short,.ascending).all()
    }
    
    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self).flatMap(to:User.self) { acronym in
            try acronym.user.get(on: req)
        }
    }
    
    

}
