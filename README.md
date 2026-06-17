# LogSystem

A lightweight logging utility that supports multiple output methods.

Each log message includes debugging information such as:
 - Timestamp (ISO8601 Format)
 - Log level (DEBUG, INFO, NOTICE, ERROR, FAULT)
 - Category
 - Thread identifier
 - Source file and line number
 - Function name

## Console Logger Example output
```text
2026-06-11T06:21:15.782Z [DEBUG] [LifeCycle] [MainThread] [SplashViewController.swift:21] [init(viewModel:)]
SplashViewController init
```

## LogSystemMacro

`@LogSystem` automatically generates multiple logging systems.

### What You Write

```swift
@LogSystem
public enum Log {
    
    public enum LoggerType: String {
        case network = "Network"
        case lifeCycle = "LifeCycle"
    }
    
    public static let subsystem: String = Bundle.main.bundleIdentifier ?? "com.hosungkim.log"
}
```

### What the Macro Generates

```swift
public enum Log {
    
    private enum LoggerType: String {
        case network = "Network"
        case lifeCycle = "LifeCycle"
    }
    
    public static let subsystem: String = Bundle.main.bundleIdentifier ?? "com.hosungkim.log"
    
    
    private static let `default` = ConsoleLogger(subsystem: subsystem, category: "Default")
    
    public static let network = ConsoleLogger(subsystem: subsystem, category: LoggerType.network.rawValue)
    
    public static let lifeCycle = ConsoleLogger(subsystem: subsystem, category: LoggerType.lifeCycle.rawValue)
    
    public static func d(_ objects: Any?..., separator: String = " ", method: ConsoleLogger.OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        `default`.d(objects, separator: separator, method: method, fileName: fileName, line: line, funcName: funcName)
    }
    
    public static func i(_ objects: Any?..., separator: String = " ", method: ConsoleLogger.OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        `default`.i(objects, separator: separator, method: method, fileName: fileName, line: line, funcName: funcName)
    }
    
    public static func n(_ objects: Any?..., separator: String = " ", method: ConsoleLogger.OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        `default`.n(objects, separator: separator, method: method, fileName: fileName, line: line, funcName: funcName)
    }
    
    public static func e(_ objects: Any?..., separator: String = " ", method: ConsoleLogger.OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        `default`.e(objects, separator: separator, method: method, fileName: fileName, line: line, funcName: funcName)
    }
    
    public static func f(_ objects: Any?..., separator: String = " ", method: ConsoleLogger.OutputMethod = .oslog, fileName: String = #fileID, line: Int = #line, funcName: String = #function) {
        `default`.f(objects, separator: separator, method: method, fileName: fileName, line: line, funcName: funcName)
    }
}
```

### Usage

```swift
// 1. Standard logging using the default channel
Log.i("App successfully started.")

// 2. Domain-specific logging via automatically generated static properties
Log.network.d("GET /v1/users", response)
Log.lifeCycle.i("SplashViewController init")
```
