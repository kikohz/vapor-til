import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    router.post("api","login") { req -> Future<LoginRequest> in
        return try req.content.decode(LoginRequest.self).flatMap(to: LoginRequest.self) { loginRequest in
            print(loginRequest.email)
            print(loginRequest.password)
            
            return loginRequest.save(on: req)
        }
    }
    
    
    router.post("api","registered") { req -> HTTPStatus in
         _ =  try req.content.decode(LoginRequest.self).flatMap(to: LoginRequest.self) { loginRequest in
            return loginRequest.save(on: req)
        }
        
        return .ok
    }
    
    router.post("api","acronyms") { req -> Future<Acronym> in
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            return acronym.save(on: req)
        }
    }
    
    router.get("api","user","query") { req -> Future<[LoginRequest]> in
        return LoginRequest.query(on: req).all()
    }
    
    router.get("api","user",LoginRequest.parameter) { req -> Future<LoginRequest> in
        return try req.parameters.next(LoginRequest.self)
    }
    
    router.put("api", "registered",LoginRequest.parameter) { req-> Future<LoginRequest> in
        return try flatMap(to: LoginRequest.self, req.parameters.next(LoginRequest.self), req.content.decode(LoginRequest.self)) {  login, updateLogin in
//            login.email = updateLogin.email
//            login.password = updateLogin.password
            return login.save(on: req)
        }
    }
    
    router.delete("api", "user") {req -> Future<HTTPStatus> in
        return try req.parameters.next(LoginRequest.self).flatMap(to: HTTPStatus.self) { login in
            return login.delete(on: req).transform(to: HTTPStatus.noContent)
        }
    }
    
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return try Acronym.query(on: req).group(.or) { or in
            try or.filter(\.short == searchTerm)
            try or.filter(\.long == searchTerm)
            }.all()
    }
    
    router.get("api","acronyms","search") {req -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at:"term"] else {
            throw Abort(.badRequest)
        }
        return try Acronym.query(on: req).filter(\.short == searchTerm).all()
    }
    
    router.get("api","acronyms","first") {req ->Future<Acronym> in
        return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
            
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
    }
    
    router.get("api","acronyms","sorted") {req ->Future<[Acronym]> in
        return try Acronym.query(on: req).sort(\.short,.ascending).all()
    }
}
