import SwiftUI

// MARK: - App State

struct AppState {
    var isLoading = false
    var isDarkTheme = false
    var counter = 0
}

// MARK: - Actions

enum AppAction {
    case loader(LoaderAction)
    case counter(CounterAction)
    case theme(ThemeAction)
}

enum LoaderAction {
    case toggle(Bool)
}

enum CounterAction {
    case increase
    case update(Int)
    case fetchFromStorage
    case saveToStorage
}

enum ThemeAction {
    case initialize
    case setBlack
    case setWhite
}


// MARK: - Effects

enum AppEffect {
    case loader(LoaderEffect)
    case counter(CounterEffect)
    case theme(ThemeEffect)
}

enum LoaderEffect {
    case empty
}

enum CounterEffect {
    case fetchFromStorage
    case saveToStorage(Int)
}

enum ThemeEffect {
    case fetchTheme
    case saveTheme(Bool)
}

// MARK: - Protocols

protocol ReducerProtocol {
    associatedtype Action
    associatedtype Effect
    func reduce(state: inout AppState, action: Action) -> [Effect]
}

protocol EffectHandlerProtocol: AnyObject {
    associatedtype Action
    associatedtype Effect
    init(_ services: ServiceContainerProtocol)
    func handle(effect: Effect, dispatch: @escaping @Sendable (Action) -> Void)
}

// MARK: - Reducers

struct AppReducer: ReducerProtocol {
    let loader = LoaderReducer()
    let counter = CounterReducer()
    let theme = ThemeReducer()
    
    func reduce(state: inout AppState, action: AppAction) -> [AppEffect] {
        switch action {
        case .loader(let action):
            return loader.reduce(state: &state, action: action).map { .loader($0) }
        case .counter(let action):
            return counter.reduce(state: &state, action: action).map { .counter($0) }
        case .theme(let action):
            return theme.reduce(state: &state, action: action).map { .theme($0) }
        }
    }
}

struct LoaderReducer: ReducerProtocol {
    func reduce(state: inout AppState, action: LoaderAction) -> [LoaderEffect] {
        switch action {
        case .toggle(let value):
            state.isLoading = value
        }
        return []
    }
}

struct CounterReducer: ReducerProtocol {
    func reduce(state: inout AppState, action: CounterAction) -> [CounterEffect] {
        switch action {
        case .increase:
            state.counter += 1
            return []
        case .update(let value):
            state.counter = value
            return []
        case .fetchFromStorage:
            return [.fetchFromStorage]
        case .saveToStorage:
            return [.saveToStorage(state.counter)]
        }
    }
}

struct ThemeReducer: ReducerProtocol {
    func reduce(state: inout AppState, action: ThemeAction) -> [ThemeEffect] {
        switch action {
        case .initialize:
            return [.fetchTheme]
        case .setBlack:
            state.isDarkTheme = true
            return [.saveTheme(true)]
        case .setWhite:
            state.isDarkTheme = false
            return [.saveTheme(false)]
        }
    }
}

// MARK: - Effect Handlers

class BaseEffectHandler<A, E>: EffectHandlerProtocol {
    typealias Action = A
    typealias Effect = E

    let services: ServiceContainerProtocol

    required init(_ services: ServiceContainerProtocol) {
        self.services = services
    }

    func handle(effect: E, dispatch: @escaping @Sendable (A) -> Void) {
        fatalError("Must override in subclass")
    }
}

final class LoaderEffectHandler: BaseEffectHandler<AppAction, LoaderEffect> {
    override func handle(effect: LoaderEffect, dispatch: @escaping (AppAction) -> Void) {
    }
}


final class CounterEffectHandler: BaseEffectHandler<AppAction, CounterEffect> {
    override func handle(effect: CounterEffect, dispatch: @escaping (AppAction) -> Void) {
        Task {
            switch effect {
            case .fetchFromStorage:
                await MainActor.run { dispatch(.loader(.toggle(true))) }
                let value = await services.storage.getCounter()
                await MainActor.run {
                    dispatch(.counter(.update(value)))
                    dispatch(.loader(.toggle(false)))
                }
            case .saveToStorage(let value):
                await services.storage.setCounter(value)
            }
        }
    }
}

final class ThemeEffectHandler: BaseEffectHandler<AppAction, ThemeEffect> {
    override func handle(effect: ThemeEffect, dispatch: @escaping (AppAction) -> Void) {
        Task {
            switch effect {
            case .fetchTheme:
                let isDark = await services.storage.getIsDarkTheme()
                await MainActor.run {
                    dispatch(.theme(isDark ? .setBlack : .setWhite))
                }
            case .saveTheme(let value):
                await services.storage.setIsDarkTheme(value)
            }
        }
    }
}

// MARK: - Services

protocol ServiceContainerProtocol {
    var storage: StorageServiceProtocol { get }
    var network: NetworkServiceProtocol { get }
}

struct ServiceContainer: ServiceContainerProtocol {
    let storage: StorageServiceProtocol
    let network: NetworkServiceProtocol
}

protocol StorageServiceProtocol {
    func getCounter() async -> Int
    func setCounter(_ value: Int) async
    func getIsDarkTheme() async -> Bool
    func setIsDarkTheme(_ value: Bool) async
}

protocol NetworkServiceProtocol {
    func pullCounter() async -> Int
}

final class StorageService: StorageServiceProtocol {
    func getCounter() async -> Int {
        try? await Task.sleep(for: .milliseconds(100))
        return UserDefaults.standard.integer(forKey: "counter")
    }

    func setCounter(_ value: Int) async {
        try? await Task.sleep(for: .milliseconds(100))
        UserDefaults.standard.set(value, forKey: "counter")
    }

    func getIsDarkTheme() async -> Bool {
        try? await Task.sleep(for: .milliseconds(100))
        return UserDefaults.standard.bool(forKey: "is_dark_theme")
    }

    func setIsDarkTheme(_ value: Bool) async {
        try? await Task.sleep(for: .milliseconds(100))
        UserDefaults.standard.set(value, forKey: "is_dark_theme")
    }
}

final class NetworkService: NetworkServiceProtocol {
    func pullCounter() async -> Int {
        try? await Task.sleep(for: .seconds(1))
        return Int.random(in: 1...99)
    }
}

// MARK: - Store

final class Store: ObservableObject {
    @Published private(set) var state = AppState()
    
    private let reducer = AppReducer()
    private let loaderHandler: LoaderEffectHandler
    private let counterHandler: CounterEffectHandler
    private let themeHandler: ThemeEffectHandler

    init(services: ServiceContainerProtocol) {
        self.loaderHandler = LoaderEffectHandler(services)
        self.counterHandler = CounterEffectHandler(services)
        self.themeHandler = ThemeEffectHandler(services)
    }

    func dispatch(_ action: AppAction) {
        let effects = reducer.reduce(state: &state, action: action)
        effects.forEach(handle)
    }

    private func handle(_ effect: AppEffect) {
        switch effect {
        case .loader(let e):
            loaderHandler.handle(effect: e, dispatch: dispatch)
        case .counter(let e):
            counterHandler.handle(effect: e, dispatch: dispatch)
        case .theme(let e):
            themeHandler.handle(effect: e, dispatch: dispatch)
        }
    }
}


// MARK: - View

struct ContentView: View {
    @ObservedObject var store: Store

    var body: some View {
        VStack(spacing: 20) {
            Text("Counter: \(store.state.counter)")
                .font(.largeTitle)

            if store.state.isLoading {
                ProgressView()
            }

            Button("➕ Increase") {
                store.dispatch(.counter(.increase))
            }

            Button("📡 Load") {
                store.dispatch(.counter(.fetchFromStorage))
            }

            Button("💾 Save") {
                store.dispatch(.counter(.saveToStorage))
            }

            Button("🌒 Toggle Theme") {
                let new = !store.state.isDarkTheme
                store.dispatch(.theme(new ? .setBlack : .setWhite))
            }
        }
        .padding()
        .preferredColorScheme(store.state.isDarkTheme ? .dark : .light)
    }
}

// MARK: - Preview

#Preview {
    ContentView(store: Store(services: ServiceContainer(storage: StorageService(), network: NetworkService())))
}
