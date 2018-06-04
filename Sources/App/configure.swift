import FluentMySQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentMySQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
//    / middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
//    middlewares.use(DateMiddleware.self)
    services.register(middlewares)

//    // Configure a SQLite database
//    let sqlite = try SQLiteDatabase(storage: .memory)
    
    // 1
    var commandConfig = CommandConfig.default()
    // 2
    commandConfig.use(RevertCommand.self, as: "revert")
    // 3
    services.register(commandConfig)
    
    //config mysql
    var databasesConfig = DatabasesConfig()
    
    let mysqlDatabaseConfig = MySQLDatabaseConfig(hostname: "gz-cdb-o7oyj6gu.sql.tencentcdb.com", port: 62575, username: "root", password: "Wx787169", database: "vapor")
    let database = MySQLDatabase(config: mysqlDatabaseConfig)
    
    
    databasesConfig.add(database: database, as: .mysql)
    services.register(databasesConfig)

    /// Configure migrations
    var migrations = MigrationConfig()
    //注册
    migrations.add(model: User.self, database: .mysql)
    migrations.add(model: Acronym.self, database: .mysql)
    migrations.add(model: LoginRequest.self, database: .mysql)
    
    services.register(migrations)

}
