//
//  File.swift
//
//
//  Created by Damon on 2022/1/12.
//

import Foundation
import Logging
import Vapor

public typealias LogComplete = ((_ level: Logger.Level, _ message: Logger.Message, _ metadata: Logger.Metadata?)->Void)

public struct DDLoggerOutputType: OptionSet {
    public static let terminal = DDLoggerOutputType(rawValue: 1)
    public static let file = DDLoggerOutputType(rawValue: 2)
    public static let database = DDLoggerOutputType(rawValue: 4)

    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}


extension Request {
    var DDLogger: Logger {
        return self.DDLogger(outputType: [.terminal, .database])
    }
    
    func DDLogger(outputType: DDLoggerOutputType = .terminal, logComplete: LogComplete? = nil) -> Logger {
        return Logger.init(label: "DDLogger") { label in
            HDLoggerHandler.init(req: self, outputType: outputType, logComplete: logComplete)
        }
    }
}

public struct HDLoggerHandler: LogHandler {
    private var uuid: String = "\(UUID())"
    private var outputType: DDLoggerOutputType = .terminal
    private var logComplete: LogComplete?
    private var request: Request?
    //MARK: - ouput manager
    private var fileLogger: SimpleFileLogger
    //MARK: - init
    public init(req: Request? = nil, outputType: DDLoggerOutputType = .file, logComplete: LogComplete? = nil) {
        self.request = req
        self.outputType = outputType
        self.logComplete = logComplete
        self.fileLogger = SimpleFileLogger()
        self.metadata["ID"] = .string(self.uuid)
    }


    //MARK: - LogHandler
    public var logLevel: Logger.Level = .info
    public var metadata: Logger.Metadata = [:]
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        let _metadata = self.metadata.merging(metadata ?? [:], uniquingKeysWith: { (_, new) in new })
        let _message = "[ \(level.description.uppercased()) ] DDLogger > \(self._currentTime()) : [\(self._prettify(_metadata).map { " \($0)" } ?? "")] \(message) (\(file):\(line)) - (\(source):\(function))\n"
        if self.outputType.contains(.file) {
            self.fileLogger.log(_message, level: level)
        }
        if let req = self.request {
            if self.outputType.contains(.terminal) {
                req.logger.log(level: level, message, metadata: _metadata, source: source, file: file, function: function, line: line)
            }
            if self.outputType.contains(.database) {
                let model = DDLoggerModel()
                model.uuid = self.uuid
                model.level = level.description.uppercased()
                model.message = _message
                _ = model.save(on: req.db)
            }
        }
        self.logComplete?(level, message, _metadata)
    }
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }
}

extension HDLoggerHandler {
    func _currentTime() -> String {
        var time = time_t(Date().timeIntervalSince1970)
        var buffer = [CChar](repeating: 0, count: 64)
        var tmStruct = tm()
        gmtime_r(&time, &tmStruct)
        strftime(&buffer, buffer.count, "%Y-%m-%d %H:%M:%S", &tmStruct)
        return String(cString: buffer)
    }

    func _prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty ? metadata.map { "\($0): \($1)" }.joined(separator: " ") : nil
    }
}
