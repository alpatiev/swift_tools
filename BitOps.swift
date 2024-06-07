//
//  BitOps.swift
//  ***********
//
//  Created by Nikita Alpatiev on 6/7/23
//

import Foundation

// MARK: - AND

// MARK: - OR

// MARK: - XOR

/// XOR swap,
/// pretty much like GCC doing that.
@discardableResult
public func xorswap<Num: BinaryInteger>(_ lhs: inout Num, _ rhs: inout Num) -> (Num, Num) {
    lhs = rhs ^ lhs
    rhs = lhs ^ rhs
    lhs = rhs ^ lhs
    return (lhs, rhs)
}
