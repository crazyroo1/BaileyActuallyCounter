//
//  File.swift
//  
//
//  Created by Turner Eison on 1/15/22.
//

import Foundation
import Vapor

struct WebsocketMessage<T: Codable>: Codable {
    let client: UUID
    let data: T
}

extension ByteBuffer {
    func decodeWebsocketMessage<T: Codable>(_ type: T.Type) -> WebsocketMessage<T>? {
        try? JSONDecoder().decode(WebsocketMessage<T>.self, from: self)
    }
}

struct Connect: Codable {
    let connect: Bool
}
