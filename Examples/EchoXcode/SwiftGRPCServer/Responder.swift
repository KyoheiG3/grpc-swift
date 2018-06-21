//
//  Responder.swift
//  SwiftGRPCServer
//
//  Created by Kyohei Ito on 2018/06/16.
//  Copyright © 2018年 Google. All rights reserved.
//

import SwiftGRPC
import SwiftProtobuf

public protocol Responder {
    associatedtype InputType: Message
    associatedtype OutputType: Message
}

public protocol UnaryResponder: Responder {
    func respond<S>(request: InputType, stream: S) throws -> OutputType where S.Responder == Self, S: UnaryStreaming
}

public protocol ServerResponder: Responder {
    func respond<S>(request: InputType, stream: S) throws -> ServerStatus? where Self == S.Responder, S: ServerStreaming, OutputType == S.SentType
}

public protocol ClientResponder: Responder {
    func respond<S>(stream: S) throws -> OutputType? where S.Responder == Self, S: ClientStreaming, InputType == S.ReceivedType
}

public protocol BidirectionalResponder: Responder {
    func respond<S>(stream: S) throws -> ServerStatus? where Self == S.Responder, S: BidirectionalStreaming, InputType == S.ReceivedType, OutputType == S.SentType
}
