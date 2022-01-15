//
//  File.swift
//  
//
//  Created by Turner Eison on 1/15/22.
//

import Foundation
import Vapor

open class WebsocketClients {
    var eventLoop: EventLoop
    var storage: [WebSocketClient]
    
    var active: [WebSocketClient] {
        self.storage.filter { !$0.socket.isClosed }
    }

    init(eventLoop: EventLoop, clients: [WebSocketClient] = []) {
        self.eventLoop = eventLoop
        self.storage = clients
    }
    
    func add(_ client: WebSocketClient) {
        self.storage.append(client)
    }

    deinit {
        let futures = self.storage.map { $0.socket.close() }
        try! self.eventLoop.flatten(futures).wait()
    }
}
