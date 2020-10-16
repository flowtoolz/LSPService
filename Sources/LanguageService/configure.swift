import Vapor
import Foundation

public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.logger.logLevel = .warning
    app.http.server.configuration.serverName = "Language Service Host"
    try registerRoutes(on: app)
    startProcessingConsoleInput(app: app)
}

fileprivate func startProcessingConsoleInput(app: Application) {
    app.console.output(ConsoleInputProcessing.initialOutput().consoleText())
    processNextConsoleInput(app: app)
}

fileprivate func processNextConsoleInput(app: Application) {
    print(ConsoleInputProcessing.inputPrefix, terminator: "")
    
    let eventLoop = app.eventLoopGroup.next()
    
    let didReadConsole = app.threadPool.runIfActive(eventLoop: eventLoop) {
        app.console.input()
    }
    
    didReadConsole.whenSuccess { input in
        app.console.output(ConsoleInputProcessing.response(forInput: input).consoleText())
        processNextConsoleInput(app: app)
    }
    
    didReadConsole.whenFailure { error in
        app.logger.error(.init(stringLiteral: error.localizedDescription))
    }
}
