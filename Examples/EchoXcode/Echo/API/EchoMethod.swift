//
//  EchoMethod.swift
//  Echo
//
//  Created by Kyohei Ito on 2018/06/12.
//  Copyright © 2018年 Google. All rights reserved.
//

import SwiftGRPCClient

enum EchoMethod: String, CallMethod {
    case update = "Update"
    case collect = "Collect"
    case expand = "Expand"
    case echo = "Get"

    static let service = "echo.Echo"

    var path: String {
        return "/\(EchoMethod.service)/\(rawValue)"
    }
}
