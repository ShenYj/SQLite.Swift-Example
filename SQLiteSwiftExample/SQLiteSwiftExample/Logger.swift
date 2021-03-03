//
//  Logger.swift
//  SQLiteSwiftExample
//
//  Created by ShenYj on 2021/03/03.
//
//  Copyright (c) 2021 ShenYj <shenyanjie123@foxmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import CocoaLumberjack
import Then

extension DDLogFlag {
    public var level: String {
        switch self {
        case DDLogFlag.error: return "❤️ ERROR"
        case DDLogFlag.warning: return "💛 WARNING"
        case DDLogFlag.info: return "💙 INFO"
        case DDLogFlag.debug: return "💚 DEBUG"
        case DDLogFlag.verbose: return "💜 VERBOSE"
        default: return "☠️ UNKNOWN"
        }
    }
}

private class LogFormatter: NSObject, DDLogFormatter {
    
    static let dateFormatter = DateFormatter().then { $0.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS" }
    
    public func format(message logMessage: DDLogMessage) -> String? {
        let timestamp = LogFormatter.dateFormatter.string(from: logMessage.timestamp)
        let level = logMessage.flag.level
        let filename = logMessage.fileName
        let function = logMessage.function ?? ""
        let line = logMessage.line
        let message = logMessage.message.components(separatedBy: "\n").joined(separator: "\n    ")
        return "\(timestamp) \(level) \(filename).\(function):\(line) - \(message)"
    }
    
    private func formattedDate(from date: Date) -> String { return LogFormatter.dateFormatter.string(from: date) }
    
}

/// A shared instance of `Logger`.
let log = Logger()

final class Logger {
    
    // MARK: Initialize
    
    init() {
        setenv("XcodeColors", "YES", 0)
        
        #if DEBUG
        // DDos
        DDOSLogger.sharedInstance.do {
            $0.logFormatter = LogFormatter()
            DDLog.add($0)
        }
        
        #if DEBUGLOG
        // File logger
        DDFileLogger().do {
            $0.rollingFrequency = TimeInterval(60 * 60 * 24)  // 24 hours
            $0.logFileManager.maximumNumberOfLogFiles = 7
            DDLog.add($0)
        }
        #endif
        
        #endif
    }
    
    
    // MARK: Logging
    
    func error( _ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line ) {
        #if DEBUG
        let message = self.message(from: items)
        DDLogError(message, file: file, function: function, line: line)
        #endif
    }
    
    func warning( _ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line ) {
        #if DEBUG
        let message = self.message(from: items)
        DDLogWarn(message, file: file, function: function, line: line)
        #endif
    }
    
    func info( _ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line ) {
        #if DEBUG
        let message = self.message(from: items)
        DDLogInfo(message, file: file, function: function, line: line)
        #endif
    }
    
    func debug( _ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line ) {
        #if DEBUG
        let message = self.message(from: items)
        DDLogDebug(message, file: file, function: function, line: line)
        #endif
    }
    
    func verbose( _ items: Any..., file: StaticString = #file, function: StaticString = #function, line: UInt = #line ) {
        #if DEBUG
        let message = self.message(from: items)
        DDLogVerbose(message, file: file, function: function, line: line)
        #endif
    }
    
    
    // MARK: Utils
    
    private func message(from items: [Any]) -> String {
        return items
            .map { String(describing: $0) }
            .joined(separator: " ")
    }
    
}
