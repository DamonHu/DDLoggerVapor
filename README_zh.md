# DDLoggerVapor

<a href="https://vapor.codes">
        <img src="http://img.shields.io/badge/vapor-4.0-brightgreen.svg" alt="Vapor 3">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-5.2-brightgreen.svg" alt="Swift 4.1">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>

适配[swift-log](https://github.com/apple/swift-log)的日志输出工具，支持将日志使用文件保存和数据库保存。为`Vapor`框架的日志设计。


## 安装

Add this dependency to your Package.swift:

```
dependencies: [
    .package(url: "https://github.com/DamonHu/DDLoggerVapor.git", from: "4.1.3"),
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "DDLoggerVapor", package: "DDLoggerVapor")
    ])
]
```

## 使用

### 配置数据库（可选）

如果需要数据库保存，在`configure.swift`文件的`public func configure(_ app: Application) throws`中，添加

```
app.migrations.add(DDLoggerCreateModel(), to: .mysql)
```

记得导入`import DDLoggerVapor`

### 打印日志

```
import DDLoggerVapor


req.DDLogger.info("message")
```

默认在终端输出同时保存在数据库。如果你仅仅想在终端保存，可以调用

```
req.DDLogger(outputType: .terminal).info("message")
```

### 1.2、使用文件存储

使用文件存储可以摆脱数据库，每种类型保存在不同的log文件中。例如`debug.log`、`error.log`。

调用方式需要指定类型：

```
req.DDLogger(outputType: .file).info("message")
```

文件保存目录：

|Linux |	macOS |
|----|----|
|/var/log/Vapor/|	~/Library/Caches/Vapor/|


## Other

Special thanks to the following excellent projects for their ideas

* [swift-log](https://github.com/apple/swift-log)
* [swift-log-file](https://github.com/crspybits/swift-log-file)
* [vapor-simple-file-logger](https://github.com/hallee/vapor-simple-file-logger)
