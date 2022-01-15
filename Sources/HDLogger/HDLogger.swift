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

public struct HDLoggerOutputType: OptionSet {
    public static let terminal = HDLoggerOutputType(rawValue: 1)
    public static let file = HDLoggerOutputType(rawValue: 2)
    public static let database = HDLoggerOutputType(rawValue: 4)

    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public struct HDLogger {
    //MARK: - Get new Logger
    public static func logger(req: Request? = nil, label: String = "HDLogger", outputType: HDLoggerOutputType = .file, excludeLogLevels: [Logger.Level] = [], logComplete: LogComplete? = nil) -> Logger {
        return Logger.init(label: label) { label in
            HDLoggerHandler.init(req: req, label: label, outputType: outputType, excludeLogLevels: excludeLogLevels, logComplete: logComplete)
        }
    }
}

public struct HDLoggerHandler: LogHandler {
    private var label: String
    private var uuid: String = "\(UUID())"
    private var outputType: HDLoggerOutputType = .terminal
    private var excludeLogLevels: [Logger.Level]
    private var logComplete: LogComplete?
    private var request: Request?
    //MARK: - ouput manager
    private var fileLogger: SimpleFileLogger
    //MARK: - init
    public init(req: Request? = nil, label: String = "HDLogger" , outputType: HDLoggerOutputType = .file, excludeLogLevels: [Logger.Level] = [], logComplete: LogComplete? = nil) {
        self.request = req
        self.label = label
        self.outputType = outputType
        self.excludeLogLevels = excludeLogLevels
        self.logComplete = logComplete
        self.fileLogger = SimpleFileLogger()
        self.metadata["ID"] = .string(self.uuid)
    }


    //MARK: - LogHandler
    public var logLevel: Logger.Level = .info
    public var metadata: Logger.Metadata = [:]
    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        guard !self.excludeLogLevels.contains(level) else {
            return
        }
        let _metadata = self.metadata.merging(metadata ?? [:], uniquingKeysWith: { (_, new) in new })
        let _message = "[ \(level.description.uppercased()) ] \(self.label) > \(self._currentTime()) : [\(self._prettify(_metadata).map { " \($0)" } ?? "")] \(message) (\(file):\(line)) - (\(source):\(function))\n"
        if self.outputType.contains(.file) {
            self.fileLogger.log(_message, level: level)
        }
        if let req = self.request {
            if self.outputType.contains(.terminal) {
                req.logger.log(level: level, message, metadata: _metadata, source: source, file: file, function: function, line: line)
            }
            if self.outputType.contains(.database) {
                let model = HDLoggerModel()
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
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd-HH:mm:ss.SSS"
        return format.string(from: Date())
    }

    func _prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty ? metadata.map { "\($0): \($1)" }.joined(separator: " ") : nil
    }
}
