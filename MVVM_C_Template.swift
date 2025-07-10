import SwiftUI
import Combine

// MARK: - MVVM + C template
/// Simple yet powerful implementation of well-known MVVM design pattern.
/// Provides module building interface, allows easy DI in Coordinator (which should be also constructed in DI somewhere).
/// Additionally, `ModuleState` serves as screen-specific `@Published` for providing slice of the App's state. 
/// (I'm also suggesting to inject only part of your App state, due to performance overhead and separation of concerns issues,
/// e.g. **appState.map(\.vmSpecificState).assign(to: \.state, on: vm).store(in: &vm.cancellables)**)

protocol ModuleState: Equatable {
    static var `default`: Self { get }
}

protocol AnyViewModel: AnyObject {
    associatedtype State: ModuleState
    associatedtype Output
    init(state: State, output: Output?)
}

class BaseViewModel<State: ModuleState, Output, Content: View>: ObservableObject, AnyViewModel, Loggable {
    typealias RootView = Content
    private weak var _output: AnyObject?
    var output: Output? { _output as? Output }
    var cancellables = Set<AnyCancellable>()
    
    required init(state: State, output: Output? = nil) {
        self._output = output as AnyObject?
        setup(state: state)
        logAlloc()
    }
    
    deinit {
        logDealloc()
    }
    
    func setup(state: State) {}
    
    static func preview(
        _ configure: ((inout State) -> Void)? = nil
    ) -> Self {
        var s = State.default
        configure?(&s)
        return Self(state: s, output: nil)
    }
}

protocol BaseView: View {
    associatedtype VM
    init(viewModel: VM)
}

protocol BaseViewController {
    associatedtype VM
    init(viewModel: VM)
}

protocol Routable {
    func viewController() -> UIViewController
}

struct SUIModule<VM: AnyViewModel, V: BaseView>: Routable where V.VM == VM {
    private let state: VM.State
    private let output: VM.Output?

    init(state: VM.State = .default, output: VM.Output? = nil) {
        self.state = state
        self.output = output
    }

    func view() -> V {
        V(viewModel: VM(state: state, output: output))
    }

    func viewController() -> UIViewController {
        UIHostingController(rootView: view())
    }
}

struct UIKitModule<VM: AnyViewModel, VC: BaseViewController>: Routable where VC: UIViewController, VC.VM == VM {
    private let state: VM.State
    private let output: VM.Output?

    init(state: VM.State = .default, output: VM.Output? = nil) {
        self.state = state
        self.output = output
    }

    func viewController() -> UIViewController {
        VC(viewModel: VM(state: state, output: output))
    }
}

enum NavigationError: LocalizedError {
    case noWindow
    case notResolved
    case notResolvedNavigation
    case invalidPopSteps
    
    var errorDescription: String? {
        switch self {
        case .noWindow:
            return "No UIWindow was set on the coordinator."
        case .notResolved:
            return "Requested view controller could not be resolved from screen registry."
        case .notResolvedNavigation:
            return "Navigation controller is not available. Use setNavRoot() first."
        case .invalidPopSteps:
            return "Cannot pop the requested number of steps — stack too shallow."
        }
    }
}

final class Coordinator: Loggable {
    private let screens: [Route: () -> Routable]
    private var window: UIWindow?
    private var navigationController: UINavigationController?

    
    init(_ screens: [Route: () -> Routable]) {
        self.screens = screens
        logAlloc()
    }
    
    deinit {
        logDealloc()
    }
    
    private func getWindow() throws -> UIWindow {
        guard let window else { throw NavigationError.noWindow }
        return window
    }
    
    private func getVc(for route: Route) throws -> UIViewController {
        guard let controller = screens[route]?().viewController() else { throw NavigationError.notResolved }
        return controller
    }
    
    private func getNavVC() throws -> UINavigationController {
        guard let controller = navigationController else { throw NavigationError.notResolvedNavigation }
        return controller
    }
    
    private func transition(to controller: UIViewController) throws {
        let window = try getWindow()
        UIView.transition(
            with: window,
            duration: 0.4,
            options: [.transitionCrossDissolve, .curveEaseInOut]
        ) {
            window.rootViewController = controller
        }
    }
    
    func start(on window: UIWindow, with route: Route) throws {
        self.window = window
        window.rootViewController = try getVc(for: route)
        window.makeKeyAndVisible()
    }
    
    func setRoot(_ route: Route) throws {
        let controller = try getVc(for: route)
        try transition(to: controller)
    }
    
    func setNavRoot(with route: Route) throws {
        let controller = try getVc(for: route)
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        self.navigationController = navigationController
        try transition(to: navigationController)
    }
    
    func push(to route: Route, cut: Int = 0) throws {
        let navigation = try getNavVC()
        let controller = try getVc(for: route)
        if cut > 0 {
            let stack = navigation.viewControllers
            let trimmed = stack.dropLast(min(cut, stack.count))
            navigation.setViewControllers(Array(trimmed) + [controller], animated: true)
        } else {
            navigation.pushViewController(controller, animated: true)
        }
    }
    
    func goBack(_ steps: Int) throws {
        let navigation = try getNavVC()
        guard navigation.viewControllers.count > steps else { throw NavigationError.invalidPopSteps }
        let targetIndex = navigation.viewControllers.count - steps - 1
        let targetVC = navigation.viewControllers[targetIndex]
        navigation.popToViewController(targetVC, animated: true)
    }
    
    func goToRoot() throws {
        let navigation = try getNavVC()
        navigation.popToRootViewController(animated: true)
    }
}

// MARK: - EXAMPLE

struct SplashState: ModuleState {
    static var `default`: SplashState { .init() }
}

final class SplashOutput {}

final class SplashViewModel: BaseViewModel<SplashState, SplashOutput, SplashView> {}

struct SplashView: BaseView {
    let viewModel: SplashViewModel

    var body: some View {
        Text("Splash")
    }
}

struct MarketingState: ModuleState {
    static var `default`: MarketingState { .init() }
}

final class MarketingOutput {}

final class MarketingViewModel: BaseViewModel<MarketingState, MarketingOutput, MarketingView> {}

struct MarketingView: BaseView {
    let viewModel: MarketingViewModel

    var body: some View {
        Text("Marketing")
            .foregroundStyle(.white)
    }
}

struct OnboardingState: ModuleState {
    static var `default`: OnboardingState { .init() }
}

final class OnboardingOutput {}

final class OnboardingViewModel: BaseViewModel<OnboardingState, OnboardingOutput, OnboardingView> {}

struct OnboardingView: BaseView {
    let viewModel: OnboardingViewModel

    var body: some View {
        Text("Onboarding")
    }
}

enum Route: Hashable {
    case splash
    case marketing
    case onboarding
}

// MARK: - TEST

enum Test {
    static func run(on window: UIWindow) {
        let coordinator = Coordinator(
            [
                .splash: {
                    SUIModule<SplashViewModel, SplashView>(state: .default, output: SplashOutput())
                },
                .marketing: {
                    SUIModule<MarketingViewModel, MarketingView>(state: .default, output: MarketingOutput())
                },
                .onboarding: {
                    SUIModule<OnboardingViewModel, OnboardingView>(state: .default, output: OnboardingOutput())
                }
            ]
        )

        try? coordinator.start(on: window, with: .splash)

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            try? coordinator.setNavRoot(with: .marketing)

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            try? coordinator.push(to: .onboarding)

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            try? coordinator.goBack(1)

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            try? coordinator.setRoot(.splash)
        }
    }
}
