//
//  EchoClientResponder.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/06/16.
//  Copyright © 2018年 Google. All rights reserved.
//

import SwiftGRPC
import SwiftGRPCServer

protocol Echo_EchoClientResponder {
    typealias InputType = Echo_EchoRequest
    typealias OutputType = Echo_EchoResponse
}

protocol EchoClientResponderType: Echo_EchoClientResponder, ClientResponder {}

struct EchoClientResponder: EchoClientResponderType {
    func respond<S>(stream: S) throws -> Echo_EchoResponse? where EchoClientResponder == S.Responder, S: ClientStreaming, InputType == S.ReceivedType {
        var parts: [String] = []
        while true {
            do {
                guard let request = try stream.receive()
                    else { break }  // End of stream
                parts.append(request.text)
            } catch {
                print("collect error: \(error)")
                break
            }
        }
        var response = Echo_EchoResponse()
        response.text = "Swift echo collect: " + parts.joined(separator: " ")
        return response
    }

}
