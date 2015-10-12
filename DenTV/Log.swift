//
//  Log.swift
//  InJobSearch
//
//  Created by Dmitriy Roytman on 26.09.15.
//  Copyright (c) 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

let debugLevel: LogLevel = LogLevel.ALL

class Log {
    
    class func e(error: NSError) {
        let level = LogLevel.ERROR
        let mess = "\(error)\nCode: \(error.code)\nDescription: \(error.localizedDescription)"
        Log.m(mess, level: level)
    }
    
    class func d(mess: String) {
        let level = LogLevel.DEBUG
        Log.m(mess, level: level)
    }
    
    class func m(mess: String, level: LogLevel) {
        print("\(level.entityValue) \(mess)")
    }
    
    class func m(mess: String) {
        switch debugLevel {
        case .NONE: break
        default: print("\(debugLevel.entityValue) \(mess)")
        }
    }
    
}

enum LogLevel {
    case WARNING
    case DEBUG
    case INFO
    case ERROR
    case ALL
    case NONE
    
    var entityValue: String {
        switch self {
        case .WARNING: return "WARNING: "
        case .DEBUG: return "DEBUG: "
        case .INFO: return "INFO: "
        case .ERROR: return "ERROR: "
        case .ALL: return "ALL: "
        default: return ""
        }
    }
}