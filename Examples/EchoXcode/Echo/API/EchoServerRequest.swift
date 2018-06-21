//
//  EchoServerRequest.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/01/19.
//  Copyright © 2018年 CyberAgent, Inc. All rights reserved.
//

import Foundation
import SwiftGRPCClient

protocol Echo_EchoServerRequest {
    typealias InputType = Echo_EchoRequest
    typealias OutputType = Echo_EchoResponse
}

protocol EchoServerRequestType: Echo_EchoServerRequest, ServerStreamingRequest {}

extension EchoServerRequestType {
    var method: CallMethod {
        return EchoMethod.expand
    }
}

struct EchoServerRequest: EchoServerRequestType {
  var text = ""

  func buildRequest() -> InputType {
      var request = InputType()
      request.text = text
      return request
  }
}
