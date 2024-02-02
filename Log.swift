//
//  Log.swift
//  ******* ***
//
//  Created by Nikita Alpatiev on 1/27/24.
//

import os
import Foundation

// MARK: - LogEvent impl

public enum LogEvent {
    case message(String)
    case warning(String)
    case startedOperation(String)
    case processingOperation(String, step: Int)
    case endedOperation(String)
    case failedOperation(String, error: String = "")
}

// MARK: - LogEventCaller impl

public enum LogEventCaller: String {
    case someService1 = "SomeService1"
    case someService2 = "SomeService2"
}

// MARK: - Log impl

public struct Log {
    
    // MARK: - Private init
    
    private init() {}
    
    // MARK: - Public Methods

    public static func print(_ caller: LogEventCaller, _ logEvent: LogEvent) {
#if DEBUG
        switch logEvent {
        case .message(let string):
            Logger.unknown.info(" [\(caller.rawValue, privacy: .public)] \(string, privacy: .public)")
        case .warning(let string):
            Logger.unknown.warning(" [\(caller.rawValue, privacy: .public)] ⚠️ \(string, privacy: .public)")
        case .startedOperation(let string):
            Logger.unknown.info(" [\(caller.rawValue, privacy: .public)] ❕ \(string, privacy: .public)")
        case .processingOperation(let string, let step):
            Logger.unknown.info(" [\(caller.rawValue, privacy: .public)] ⏳ \(step, privacy: .public). \(string, privacy: .public)")
        case .endedOperation(let string):
            Logger.unknown.info(" [\(caller.rawValue, privacy: .public)] ✅ \(string, privacy: .public)")
        case .failedOperation(let string, let error):
            Logger.unknown.fault(" [\(caller.rawValue, privacy: .public)] ❌ \(string, privacy: .public) ❌ \(error, privacy: .public)")
        }
#endif
    }
}

// MARK: - Logger configuration

#if DEBUG
fileprivate extension Logger {
    
    // MARK: SUBSYSTEMS
    //
    // NOTE:
    // Describes domain of log message. Reusable.
    // All strings should be equal length in purpose of to visual consistency.
    // For example - 12 characters.
    private static let subsystem_name = "UNKNOWN"

    // MARK: CATEGORIES
    //
    // NOTE:
    //
    // Category for specific source, represents name of struct, class, protocol etc.
    // All names may be equal length in purpose of to visual consistency.
    private static let category_name = "UNKNOWN"
    
    // MARK: LOGGERS
   
    static let unknown = Logger()
}
#endif
