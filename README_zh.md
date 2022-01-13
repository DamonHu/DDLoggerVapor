# HDLogger


`Vapor`框架下的一个简单的日志输入工具，支持保存到log文件和数据库。基于[swift-log](https://github.com/apple/swift-log)，已经实现了`swift-log`的`LogHandler`协议

### 适配 `Vapor 4.0`

十分感谢以下项目提供的创意

* [swift-log](https://github.com/apple/swift-log)
* [swift-log-file](https://github.com/crspybits/swift-log-file)
* [vapor-simple-file-logger](https://github.com/hallee/vapor-simple-file-logger)

## 安装

`Package.swift`中添加`dependency`

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

## 使用

### 首先导入 `HDLogger`

```
import HDLogger
```

### 1.1、只在终端输出日志

vapor已经提供了默认的终端输出，这种模式和vapor的默认输出没区别

```
//Vapor default
req.logger.info("ddddddd")

//HDLogger
let logger = HDLogger.logger(req: req, outputType: .terminal)
logger.info("ssssss")

```

### 1.2、只将日志保存到log文件

保存文件的操作用不到request，所以request参数可以不用传。

log文件根据系统保存在以下文件夹，并且根据日志的level做了区分

|Linux |	macOS |
|----|----|
|/var/log/Vapor/|	~/Library/Caches/Vapor/|


```
let logger = HDLogger.logger(outputType: .file)
logger.info("ssssss")
```

### 1.3、只保存到数据库


如果需要保存到数据库，需要先创建数据库表。`HDLogger`已经内置了一个表结构，如果你想自定义，可以参考最后的自定义环节教程

#### 在`configure.swift`文件中添加

```
public func configure(_ app: Application) throws {
	app.migrations.add(HDLoggerCreateModel(), to: .mysql)
	//other code
}
```

#### 保存到数据库

```
let logger = HDLogger.logger(req: req, outputType: .database)
logger.info("ssssss")
```

## 自定义操作

1、`outputType` 可以自由组合，所以你可以根据需要传参，例如

```
//同时在终端输出，也保存到log文件中

let logger = HDLogger.logger(req: req, outputType: [.terminal, .file])
logger.info("ssssss")
```

2、保存或者输出完毕，我们提供了一个回调函数，你可以在该回调函数中实现其他自定义功能

```
let logger = HDLogger.logger(req: req, outputType: .file) { level, message, metadata in

	//do something 
   req.logger.error(message, metadata: metadata)
}
        
logger.info("ssssss")
```

