//
//  SimpleFileLogger.swift
//  SimpleFileLogger
//
//  Created by Hal Lee on 9/8/18.
//

import Vapor
import Logging

final class SimpleFileLogger {

    let executableName: String
    let fileManager = FileManager.default
    let fileQueue = DispatchQueue.init(label: "vaporSimpleFileLogger", qos: .utility)
    var fileHandles = [URL: Foundation.FileHandle]()

    lazy var logDirectoryURL: URL? = {
        var baseURL: URL?
#if os(macOS)
        /// ~/Library/Caches/
        if let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            baseURL = url
        } else { print("Unable to find caches directory.") }
#endif
#if os(Linux)
        baseURL = URL(fileURLWithPath: "/var/log/")
#endif

        /// Append executable name; ~/Library/Caches/executableName/ (macOS),
        /// or /var/log/executableName/ (Linux)
        do {
            if let executableURL = baseURL?.appendingPathComponent(executableName, isDirectory: true) {
                try fileManager.createDirectory(at: executableURL, withIntermediateDirectories: true, attributes: nil)
                baseURL = executableURL
            }
        } catch { print("Unable to create \(executableName) log directory.") }

        return baseURL
    }()

    init(executableName: String = "Vapor") {
        // TODO: sanitize executableName for path use
        self.executableName = executableName
    }

    deinit {
        for (_, handle) in fileHandles {
            handle.closeFile()
        }
    }

    public func log(_ string: String, level: Logger.Level) {
        let fileName = level.description.lowercased() + ".log"
        saveToFile(string, fileName: fileName)
    }

    func saveToFile(_ string: String, fileName: String) {
        guard let baseURL = logDirectoryURL else { return }

        fileQueue.async {
            let url = baseURL.appendingPathComponent(fileName, isDirectory: false)
            let output = string + "\n"

            do {
                if !self.fileManager.fileExists(atPath: url.path) {
                    try output.write(to: url, atomically: true, encoding: .utf8)
                } else {
                    let fileHandle = try self.fileHandle(for: url)
                    fileHandle.seekToEndOfFile()
                    if let data = output.data(using: .utf8) {
                        fileHandle.write(data)
                    }
                }
            } catch {
                print("SimpleFileLogger could not write to file \(url).")
            }
        }
    }

    /// Retrieves an opened FileHandle for the given file URL,
    /// or creates a new one.
    func fileHandle(for url: URL) throws -> Foundation.FileHandle {
        if let opened = fileHandles[url] {
            return opened
        } else {
            let handle = try FileHandle(forWritingTo: url)
            fileHandles[url] = handle
            return handle
        }
    }
}
