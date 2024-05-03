//
//  QuickActionHelper.swift
//  ***********
//
//  Created by Nikita Alpatiev on 2/14/23
//

import Foundation
import UIKit
import SwiftUI
import Combine

// MARK: - Quick action types

/// Represents specific type of quick action.
/// Must be presented within info.plist.
///
enum QuickActionType: String {
    case claimDiscount = "claim_discount"
    case chooseStyle = "choose_style"
    case openSettings = "open_settings"
}

/// `UIApplicationShortcutItem` implementation.
/// Reflects `QuickActionType` cases.
///
enum Action: Equatable {
    case claimDiscount
    case selectStyle
    case openSettings
    
    init?(shortcutItem: UIApplicationShortcutItem) {
        guard let type = QuickActionType(rawValue: shortcutItem.type) else { return nil }
        
        switch type {
        case .claimDiscount:
            self = .claimDiscount
        case .chooseStyle:
            self = .selectStyle
        case .openSettings:
            self = .openSettings
        }
    }
}

// MARK: - QuickActionHelper impl

final class QuickActionHandler: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = QuickActionHandler()
    
    // MARK: - Subscriptions
    
    @Published var action: Action?
    @Published var scenePhase: ScenePhase?
    
    /// Disposable bag for subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    /// Singleton -> private.
    private init() {
        initObserving()
    }
    
    // MARK: - Handle action queue
    
    /// Handle all events when scene becomes active.
    private func initObserving() {
        Publishers
            .CombineLatest($scenePhase, $action)
            .compactMap { $0.0 == .active ? $0.1 : nil }
            .sink { newValue in
                switch newValue {
                case .claimDiscount:
                    self.handleClaimDiscountAction()
                case .selectStyle:
                    self.handleSelectStyleAction()
                case .openSettings:
                    self.handleOpenSettingsAction()
                }
                
                self.action = nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Claim discount method
    
    private func handleClaimDiscountAction() {
        print(#function)
    }
    
    // MARK: - Select style method
    
    private func handleSelectStyleAction() {
        print(#function)
    }
    
    // MARK: - Open settings method
    
    private func handleOpenSettingsAction() {
        print(#function)
    }
}

// MARK: - QuickActionHelper impl


struct QuickActionHelper: ViewModifier {
    
    @Environment(\.scenePhase) var scenePhase
    private let quickActionService = QuickActionHandler.shared
    
    func body(content: Content) -> some View {
        content
            .environmentObject(quickActionService)
            .onChange(of: scenePhase) { quickActionService.scenePhase = $0 }
    }
}
