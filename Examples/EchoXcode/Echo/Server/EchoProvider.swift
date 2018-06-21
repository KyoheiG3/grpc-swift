//
//  _EchoProvider.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/06/16.
//  Copyright © 2018年 Google. All rights reserved.
//

import SwiftGRPC
import SwiftGRPCServer

struct EchoProvider: Provider {
    func provide(_ handler: Handler) throws {
        switch handler.method {
        case "/echo.Echo/Get":
            return Stream(responder: EchoUnaryResponder(), handler: handler).run()
        case "/echo.Echo/Expand":
            return Stream(responder: EchoServerResponder(), handler: handler).run()
        case "/echo.Echo/Collect":
            return Stream(responder: EchoClientResponder(), handler: handler).run()
        case "/echo.Echo/Update":
            return Stream(responder: EchoBidirectionalResponder(), handler: handler).run()
        default:
            throw Session.HandleMethodError.unknownMethod
        }
    }
}
