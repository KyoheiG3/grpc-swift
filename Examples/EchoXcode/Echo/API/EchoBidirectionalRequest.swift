//
//  EchoBidirectionalRequest.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/01/19.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import Foundation
import SwiftGRPCClient

protocol Echo_EchoBidirectionalRequest {
    typealias InputType = Echo_EchoRequest
    typealias OutputType = Echo_EchoResponse
}

protocol EchoBidirectionalRequestType: Echo_EchoBidirectionalRequest, BidirectionalStreamingRequest {}

extension EchoBidirectionalRequestType {
    var method: CallMethod {
        return EchoMethod.update
    }
}

struct EchoBidirectionalRequest: EchoBidirectionalRequestType {
    func buildRequest(_ message: String) -> InputType {
        var request = InputType()
        request.text = message
        return request
    }
}
