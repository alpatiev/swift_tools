# Table of contents. Contains name of the file and usage description.

## 1. UIDevice_iPhone_name.swift
Simple snipped that allows you get current iPhone name.
Also you can check if an iPhone has rounded screen.
Supports range from 4 to 15 Pro Max. Usage:
```
let model: IPhoneModel = UIDevice().iPhoneModelEnum
let modelName: String = UIDevice().iPhoneModelText
let isFrameless: Bool = UIDevice().isFramelessDevice
```

## 2. iPhone_iPad_screen_sizes.md
Two tables that represents all screens sizes up to 2023.


## 3. Log.swift
Basic tool for logging in-app events during debug builds.
You can specify your own log caller by adding your classes to this enum:
```
public enum LogEventCaller: String {
    case someService1 = "SomeService1"
    case someService2 = "SomeService2"
}
```

Also it is recommended to create custom loggers for specific scenarious.
For example, you can add custom logger instead default "unknown" type:
```
fileprivate extension Logger {
    static let coreMLTesting = Logger(subsystem: "CoreML", category: "Object recognition")
}
```

Default usage:
```
Log.print(.someService1, .warning("Something suspicious!"))
```
