//
// Source.swift
// No-Ri
//
// Represents the source code for the no-ri programming language.
//
// Created by Nneko Branche on 2026/11/14.
//

import Foundation
import Crypto

public typealias Byte = UInt8
public typealias Bytes = [Byte]

public struct SourceId: Hashable, Sendable, CustomStringConvertible {
    private let digest: SHA256.Digest

    init(bytes: Bytes) {
        self.digest = SHA256.hash(data: bytes)
    }

    public var description: String {
        digest.map {
            String(format: "%02x", $0)
        }.joined()
    }
}

public enum SourceType: Hashable, Sendable {
    case SourceFile(URL)
    case SourcecodeString(String)
}

public struct SourceSegment: Hashable, Sendable {
    public let sourceId: SourceId
    public let offset: Int
    public let length: Int
    
    public var boundary: Int {
        offset + length
    }

    public var bounds: Range<Int> {
        offset..<boundary
    }

    public init(id: SourceId, offset: Int, length: Int) {
        self.sourceId = id
        self.offset = offset
        self.length = length
    }

    public func isValid(for source: SourceData) -> Bool {
        sourceId == source.id &&
        offset >= 0 &&
        length >= 0 &&
        offset <= source.size &&
        length <= source.size - offset
    }
}

public struct SourceData: Sendable {
    public let id: SourceId
    public let type: SourceType
    public let bytes: Bytes

    public var path: String? {
        switch type {
        case .SourceFile(let url):
            url.path
        case .SourcecodeString(_):
            nil
        }
    }
    
    public var size: Int {
        bytes.count
    }

    public init(type: SourceType) throws {
        self.type = type

        switch type {
        case .SourceFile(let url):
            self.bytes = Bytes(try Data(contentsOf: url, options: .mappedIfSafe))

        case .SourcecodeString(let code):
            self.bytes = Bytes(code.utf8)
        }

        self.id = SourceId(bytes: self.bytes)
    }
}