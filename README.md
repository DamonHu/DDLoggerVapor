# HDLogger

### [中文文档](./README_zh.md)

A simple `Vapor` Logger provider for outputting server logs to log files or data base. Based on [swift-log](https://github.com/apple/swift-log)。The `LogHandler` of `swift-log` has implemented

### Adaptation For `Vapor 4.0`

Special thanks to the following excellent projects for their ideas

* [swift-log](https://github.com/apple/swift-log)
* [swift-log-file](https://github.com/crspybits/swift-log-file)
* [vapor-simple-file-logger](https://github.com/hallee/vapor-simple-file-logger)

## Installation

Add this dependency to your Package.swift:

```
dependencies: [
    .package(url: "https://github.com/DamonHu/HDLogger-Vapor.git", from: "4.0.1"),
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "HDLogger", package: "HDLogger-Vapor")
            ///other dependency
    ])
]
```

## Usage

### Import `HDLogger` first

```
import HDLogger
```

### 1.1、only Terminal output

Terminal output is provided by default in vapor, which is no different from that provided by default

```
//Vapor default
req.logger.info("ddddddd")

//HDLogger
let logger = HDLogger.logger(req: req, outputType: .terminal)
logger.info("ssssss")

```

### 1.2、only Saving to log file

Saving to the log file has nothing to do with the request, so you don't need to fill in the request.

outputs separate files based on the log's LogLevel. Debug logs are output to `debug.log`, error logs to `error.log`, and so on. By default, logs are output to:

|Linux |	macOS |
|----|----|
|/var/log/Vapor/|	~/Library/Caches/Vapor/|

```
let logger = HDLogger.logger(outputType: .file)
logger.info("ssssss")
```

### 1.3、only Saving to database

To save to the database, you need to create a database table first. You can use the default format. How to use the custom save format will also be described later

#### add config in `configure.swift` file

```
public func configure(_ app: Application) throws {
	app.migrations.add(HDLoggerCreateModel(), to: .mysql)
	//other code
}
```

#### Saving to database

```
let logger = HDLogger.logger(req: req, outputType: .database)
logger.info("ssssss")
```

## Custom options

1、 `outputType` can be combined freely, so it can be used in this way if there are multiple outputs

```
//Save to file and terminal output at the same time

let logger = HDLogger.logger(req: req, outputType: [.terminal, .file])
logger.info("ssssss")
```

2、 After output or saving, we provide a callback. If you want to do other functions, you can complete it in the callback

```
let logger = HDLogger.logger(req: req, outputType: .file) { level, message, metadata in

	//do something 
   req.logger.error(message, metadata: metadata)
}
        
logger.info("ssssss")
```

