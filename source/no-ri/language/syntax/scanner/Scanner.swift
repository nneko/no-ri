//
// Scanner.swift
// No-Ri
//
// Lexer for the no-ri programming language. Handles the tokenization of the source data into a 
// stream of tokens for the parser to consume. 
//
// Created by Nneko Branche on 2026/11/14.
//

public struct SourcePosition: Hashable, Sendable {
    public var line: Int
    public var column: Int

    public init(line: Int = 1, column: Int = 1) {
        self.line = line
        self.column = column
    }
}

public enum ScanMode: Hashable, Sendable {
    case Normal
    case String
    case MultilineString
    case Interpolation(depth: Int)
}


public final class Scanner {
    private let source: SourceData

    // Next unread byte offset
    private var cursor: Int = 0

    // Current source position (1-based)
    private var position = SourcePosition(line: 1, column: 1)

    // Lexical states (LIFO)
    private var states: [ScanMode] = [.Normal]

    // Trivia awaiting attachment
    private var leadingTrivia: [Trivia] = []

    // Current lexical mode
    private var mode: ScanMode {
        states.last!
    }

    // Unicode scalar operations (1-4 bytes)
    private func peek() -> Unicode.Scalar? {

    }

    private func peek(ahead: Int) -> Unicode.Scalar? {

    }

    private func advance() -> Unicode.Scalar? {

    }

    // Token operations
    public func next() -> Token {

    }

    public init(source: SourceData) {
        self.source = source
    }
}