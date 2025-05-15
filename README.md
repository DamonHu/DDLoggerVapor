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

A logging utility compatible with [swift-log](https://github.com/apple/swift-log), supporting output to both file and database. Designed specifically for the `Vapor` framework.

---

## Installation

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/DamonHu/DDLoggerVapor.git", from: "4.1.1"),
],
targets: [
    .target(name: "App", dependencies: [
        .product(name: "DDLoggerVapor", package: "DDLoggerVapor")
    ])
]
```

---

## Usage

### Configure Database (Optional)

If you want to store logs in the database, add the following to your `configure.swift` file in the `public func configure(_ app: Application) throws` method:

```swift
app.migrations.add(DDLoggerCreateModel(), to: .mysql)
```

Don't forget to import:

```swift
import DDLoggerVapor
```

---

### Logging

```swift
import DDLoggerVapor

req.DDLogger.info("message")
```

By default, logs are printed to the terminal **and** saved to the database.

If you only want terminal output:

```swift
req.DDLogger(outputType: .terminal).info("message")
```

---

### File Storage

File-based logging lets you avoid using a database. Each log level is stored in a separate file (e.g., `debug.log`, `error.log`).

To use file logging, specify the type:

```swift
req.DDLogger(outputType: .file).info("message")
```

#### File Save Locations:

| Linux             | macOS                     |
| ----------------- | ------------------------- |
| `/var/log/Vapor/` | `~/Library/Caches/Vapor/` |

---

## Other

Special thanks to the following excellent projects for their ideas and inspiration:

* [swift-log](https://github.com/apple/swift-log)
* [swift-log-file](https://github.com/crspybits/swift-log-file)
* [vapor-simple-file-logger](https://github.com/hallee/vapor-simple-file-logger)
