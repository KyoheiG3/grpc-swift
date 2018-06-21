//
//  EchoUnaryRequest.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/01/19.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import Foundation
import SwiftGRPCClient

protocol Echo_EchoUnaryRequest {
    typealias InputType = Echo_EchoRequest
    typealias OutputType = Echo_EchoResponse
}

protocol EchoUnaryRequestType: Echo_EchoUnaryRequest, UnaryStreamingRequest {}

extension EchoUnaryRequestType {
    var method: CallMethod {
        return EchoMethod.echo
    }
}

struct EchoUnaryRequest: EchoUnaryRequestType {
    var text = ""

    func buildRequest() -> InputType {
        var request = InputType()
        request.text = text
        return request
    }
}
