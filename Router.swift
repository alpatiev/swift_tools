//
//  Router.swift
//  ******* ******
//
//  Created by Alpatiev Nikita on 6/18/24.
//
//  ************ © 2024.
//  ********* ******** ******* ****
//
    
import SwiftUI

// MARK: - RoutableObjectInterface

/// Simple alias for both protocols.
typealias Routable = View & Hashable

/// Protocol that holds neccessary logic for manageable navigation.
/// `NOTE:` Dont forget calling it from the main thread only.
protocol RoutableObjectInterface: AnyObject {
    associatedtype Destination: Routable
    var stack: [Destination] { get set }
    func navigateBack(_ count: Int)
    func navigateBack(to destination: Destination)
    func navigateToRoot()
    func navigate(to destination: Destination)
    func navigate(to destinations: [Destination])
    func replace(with destinations: [Destination])
}

/// Methods to manipulate the `Routes` array.
extension RoutableObjectInterface {
    func navigateBack(_ count: Int = 1) {
        guard count > 0 else { return }
        guard count <= stack.count else {
            stack = .init(); return
        }
        stack.removeLast(count)
    }

    func navigateBack(to destination: Destination) {
        if let index = stack.lastIndex(where: { $0 == destination }) {
            guard index < stack.count && index >= 0 else { return }
            stack = Array(stack[..<Swift.min(index + 1, stack.count)])
        }
    }

    func navigateToRoot() { stack = [] }
    func navigate(to destination: Destination) { stack.append(destination) }
    func navigate(to destinations: [Destination]) { stack += destinations }
    func replace(with destinations: [Destination]) { stack = destinations }
}

// MARK: - Router

/// Router class that conforms `RoutableObjectInterface`.
/// Feel free to use your own implementation.
final class Router<Routes: Routable>: RoutableObjectInterface, ObservableObject {
    typealias Destination = Routes
    @Published var stack: [Routes] = []
}

// MARK: - RoutableNavigationStack

/// **View that returns NavigationStack with Router inside.**
///
/// 1. So-called`RouterObject` conforms `RoutableObjectInterface`, adjust as needed.
/// 2. Instance of `RouterObject` is NOT owned by `RoutableNavigationStack`.
/// 3. Root is view inside `RoutableNavigationStack` at declaratiion time.
///
struct RoutableNavigationStack<Root: View, Routes: Routable>: View {
    @ObservedObject private var router: Router<Routes>
    private let root: () -> Root
    
    init(_ router: Router<Routes>, @ViewBuilder root: @escaping () -> Root) {
        self.router = router
        self.root = root
    }

    var body: some View {
        NavigationStack(path: $router.stack) {
            root().navigationDestination(for: Routes.self) { $0.body }
        }
    }
}

// MARK: - Examples

extension Router {
    
    /// **SwiftUI router written in 50 lines of code**.
    /// `NOTE` :  Only iOS 16.0 and newer.
    ///
    /// **1. Definde enum with destinations.**
    ///
    /// enum SomeDestinations: Routable {
    ///    case somewhere
    ///
    ///    var body: some View {
    ///        switch self {
    ///        case .somewhere:
    ///            Text("We are somewhere")
    ///        }
    ///    }
    /// }
    ///
    /// **2. Handle logic in your viewmodel.**
    ///
    /// final class ViewModel: ObservableObject {
    ///    let router = Router<SomeDestinations>()
    ///    func foo() {
    ///        router.navigate(to: .somewhere)
    ///    }
    /// }
    ///
    /// **3. Handle login in your viewmodel.**
    ///
    /// struct MainContainerView: View {
    ///    @StateObject var viewModel = ViewModel()
    ///
    ///    var body: some View {
    ///        RoutableNavigationStack(viewModel.router) {
    ///            Button("Foo") {
    ///                viewModel.foo()
    ///            }
    ///        }
    ///    }
    /// }
    var example: Void {()}
}
