//
//  Result.swift
//  SwiftGRPCClient
//
//  Created by Kyohei Ito on 2018/06/12.
//  Copyright © 2018年 Google. All rights reserved.
//

public enum Result<T> {
    case success(T)
    case failure(Error)

    public var value: T? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }

    public var error: Error? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }
}
