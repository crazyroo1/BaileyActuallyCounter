//
//  File.swift
//  
//
//  Created by Turner Eison on 1/15/22.
//

import Foundation
import Vapor

open class WebSocketClient {
    open var socket: WebSocket

    public init(socket: WebSocket) {
        self.socket = socket
    }
}
