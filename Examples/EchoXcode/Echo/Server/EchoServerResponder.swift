//
//  EchoServerResponder.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/06/16.
//  Copyright © 2018年 Google. All rights reserved.
//

//import Foundation
import SwiftGRPC
import SwiftGRPCServer

protocol Echo_EchoServerResponder {
    typealias InputType = Echo_EchoRequest
    typealias OutputType = Echo_EchoResponse
}

protocol EchoServerResponderType: Echo_EchoServerResponder, ServerResponder {}

struct EchoServerResponder: EchoServerResponderType {
    func respond<S>(request: Echo_EchoRequest, stream: S) throws -> ServerStatus? where EchoServerResponder == S.Responder, S: ServerStreaming, OutputType == S.SentType {
        let parts = request.text.components(separatedBy: " ")
        for (i, part) in parts.enumerated() {
            var response = Echo_EchoResponse()
            response.text = "Swift echo expand (\(i)): \(part)"
            try stream.send(response) {
                if let error = $0 {
                    print("expand error: \(error)")
                }
            }
        }
        return .ok
    }
}
