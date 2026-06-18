# ConsoleLog

A lightweight logging utility that supports multiple output methods.

Each log message includes debugging information such as:
 - Timestamp (ISO8601 Format)
 - Log level (DEBUG, INFO, NOTICE, ERROR, FAULT)
 - Category
 - Thread identifier
 - Source file and line number
 - Function name

## `ConsoleLogger` Example output

```text
2026-06-11T06:21:15.782Z [DEBUG] [LifeCycle] [MainThread] [SplashViewController.swift:21] [init(viewModel:)]
SplashViewController init
```

## ConsoleLog Macro

`@ConsoleLoggerCategory` macro automatically generates multiple logging systems based on your enum cases.

By marking a case with the `@hidden` macro, it generates that specific logger as `private` instead of `public`, safely blocking direct access from the outside.

### What You Write

```swift
@_exported import ConsoleLog

public enum Log {
    
    @ConsoleLoggerCategory
    public enum Category: String {
        case network = "Network"
        case lifeCycle = "LifeCycle"
        
        @hidden
        case _firebase = "Firebase"
    }
    
    public static let firebase = FirebaseLogger(consoleLogger: _firebase)
}
```

### What the Macro Generates

```swift
@_exported import ConsoleLog

public enum Log {
    
    @ConsoleLoggerCategory
    public enum Category: String {
        case network = "Network"
        case lifeCycle = "LifeCycle"
        
        @hidden
        case _firebase = "Firebase"
    }
    
    private static let `default` = ConsoleLogger(category: "Default")
    
    public static let network = ConsoleLogger(category: Category.network.rawValue)
    
    public static let lifeCycle = ConsoleLogger(category: Category.lifeCycle.rawValue)
    
    private static let _firebase = ConsoleLogger(category: Category._firebase.rawValue)
    
    public static let firebase = FirebaseLogger(consoleLogger: _firebase)
    
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
let logger = ConsoleLogger(category: "Category")

logger.n("Hello, world!", 14)
```

```swift
Log.i("App successfully started.")

Log.network.d("GET /v1/users", response)
Log.lifeCycle.i("SplashViewController init")

Log.firebase.logEvent("share_image", parameters: [
  "name": name,
  "full_text": text,
])

// ❌ Compile error: '_firebase' is inaccessible due to 'private' protection level
Log._firebase.e("This will trigger a compiler error")
```
