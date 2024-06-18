# About
Tools and extensions for developing iOS/MacOS/WatchOS applications.

## 1. UIDevice_iPhone_name.swift
Simple snipped that allows you get current iPhone name.
Also you can check if an iPhone has rounded screen.
Supports range from 4 to 15 Pro Max. Usage:
```swift
let model: IPhoneModel = UIDevice().iPhoneModelEnum
let modelName: String = UIDevice().iPhoneModelText
let isFrameless: Bool = UIDevice().isFramelessDevice
```

## 2. iPhone_iPad_screen_sizes.md
Two tables that represents all screens sizes up to 2023.


## 3. Log.swift
Basic tool for logging in-app events during debug builds.
You can specify your own log caller by adding your classes to this enum:
```swift
public enum LogEventCaller: String {
    case someService1 = "SomeService1"
    case someService2 = "SomeService2"
}
```

Also it is recommended to create custom loggers for specific scenarious.
For example, you can add custom logger instead default "unknown" type:
```swift
fileprivate extension Logger {
    static let coreMLTesting = Logger(subsystem: "CoreML", category: "Object recognition")
}
```

Default usage:
```swift
Log.print(.someService1, .warning("Something suspicious!"))
```

## 4. QuickActionHelper.swift
Simple class to handle Quick Actions from the iOS manu.

## 5. BitOps.swift
A grain of bitwise operations in swift,
it will be cool to compare native methods and DIY ones. Examples:
```swift
swapxor(&a, &b) 
```

## 6. Router.swift
Simple Router written in exactly 50 lines of code. 
My goal was to create wrapper and make it as simple as possible, but controlled outside the View itself.
So you can use DI as to make lifecycle managed externaly.

Below are some usage example:
```swift
enum CustomDestination: Routable {
    case somewhere
    
    var body: some View {
        switch self {
        case .somewhere:
            Text("We are somewhere")
        }
    }
}

final class ViewModel: ObservableObject {
    let router = Router<CustomDestination>()
    
    func foo() {
        router.navigate(to: .somewhere)
    }
}


struct ContainerView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        RoutableNavigationStack(viewModel.router) {
            Button("Foo") {
                viewModel.foo()
            }
        }
    }
 }
```

