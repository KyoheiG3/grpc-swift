//
//  EchoBidirectionalResponder.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/06/21.
//  Copyright © 2018年 Google. All rights reserved.
//

import SwiftGRPC
import SwiftGRPCServer

protocol Echo_EchoBidirectionalResponder {
    typealias InputType = Echo_EchoRequest
    typealias OutputType = Echo_EchoResponse
}

protocol EchoBidirectionalResponderType: Echo_EchoBidirectionalResponder, BidirectionalResponder {}

struct EchoBidirectionalResponder: EchoBidirectionalResponderType {
    func respond<S>(stream: S) throws -> ServerStatus? where EchoBidirectionalResponder == S.Responder, S: BidirectionalStreaming, InputType == S.ReceivedType, OutputType == S.SentType {
        var count = 0
        while true {
            do {
                guard let request = try stream.receive()
                    else { break }  // End of stream
                var response = Echo_EchoResponse()
                response.text = "Swift echo update (\(count)): \(request.text)"
                count += 1
                try stream.send(response) {
                    if let error = $0 {
                        print("update error: \(error)")
                    }
                }
            } catch {
                print("update error: \(error)")
                break
            }
        }
        return .ok
    }

}
