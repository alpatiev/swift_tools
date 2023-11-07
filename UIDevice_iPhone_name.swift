import UIKit

// MARK: - UIDevice + iPhoneModelEnum + iPhoneModelText

public extension UIDevice {
    enum IPhoneModel: String {
        case iPhone_4
        case iPhone_4s
        case iPhone_5
        case iPhone_5c
        case iPhone_5s
        case iPhone_6
        case iPhone_6_Plus
        case iPhone_6s
        case iPhone_6s_Plus
        case iPhone_7
        case iPhone_7_Plus
        case iPhone_SE_1st_Generation
        case iPhone_8
        case iPhone_8_Plus
        case iPhone_X
        case iPhone_XS
        case iPhone_XS_Max
        case iPhone_XR
        case iPhone_11
        case iPhone_11_Pro
        case iPhone_11_Pro_Max
        case iPhone_SE_2nd_Generation
        case iPhone_12_Mini
        case iPhone_12
        case iPhone_12_Pro
        case iPhone_12_Pro_Max
        case iPhone_13_mini
        case iPhone_13
        case iPhone_13_Pro
        case iPhone_13_Pro_Max
        case iPhone_SE_3rd_Generation
        case iPhone_14
        case iPhone_14_Plus
        case iPhone_14_Pro
        case iPhone_14_Pro_Max
        case iPhone_15
        case iPhone_15_Plus
        case iPhone_15_Pro
        case iPhone_15_Pro_Max
        case unknown
    }
    
    /// Returns current device name in enum format.
    /// Compatible only with iPhones.
    var iPhoneModelEnum: IPhoneModel {
#if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
#else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 , value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
#endif
        switch identifier {
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return .iPhone_4
            case "iPhone4,1":                               return .iPhone_4s
            case "iPhone5,1", "iPhone5,2":                  return .iPhone_5
            case "iPhone5,3", "iPhone5,4":                  return .iPhone_5c
            case "iPhone6,1", "iPhone6,2":                  return .iPhone_5s
            case "iPhone7,2":                               return .iPhone_6
            case "iPhone7,1":                               return .iPhone_6_Plus
            case "iPhone8,1":                               return .iPhone_6s
            case "iPhone8,2":                               return .iPhone_6s_Plus
            case "iPhone9,1", "iPhone9,3":                  return .iPhone_7
            case "iPhone9,2", "iPhone9,4":                  return .iPhone_7_Plus
            case "iPhone8,4":                               return .iPhone_SE_1st_Generation
            case "iPhone10,1", "iPhone10,4":                return .iPhone_8
            case "iPhone10,2", "iPhone10,5":                return .iPhone_8_Plus
            case "iPhone10,3", "iPhone10,6":                return .iPhone_X
            case "iPhone11,2":                              return .iPhone_XS
            case "iPhone11,4", "iPhone11,6":                return .iPhone_XS_Max
            case "iPhone11,8":                              return .iPhone_XR
            case "iPhone12,1":                              return .iPhone_11
            case "iPhone12,3":                              return .iPhone_11_Pro
            case "iPhone12,5":                              return .iPhone_11_Pro_Max
            case "iPhone12,8":                              return .iPhone_SE_2nd_Generation
            case "iPhone13,1":                              return .iPhone_12_Mini
            case "iPhone13,2":                              return .iPhone_12
            case "iPhone13,3":                              return .iPhone_12_Pro
            case "iPhone13,4":                              return .iPhone_12_Pro_Max
            case "iPhone14,4":                              return .iPhone_13_mini
            case "iPhone14,5":                              return .iPhone_13
            case "iPhone14,2":                              return .iPhone_13_Pro
            case "iPhone14,3":                              return .iPhone_13_Pro_Max
            case "iPhone14,6":                              return .iPhone_SE_3rd_Generation
            case "iPhone14,7":                              return .iPhone_14
            case "iPhone14,8":                              return .iPhone_14_Plus
            case "iPhone15,2":                              return .iPhone_14_Pro
            case "iPhone15,3":                              return .iPhone_14_Pro_Max
            case "iPhone15,4":                              return .iPhone_15
            case "iPhone15,5":                              return .iPhone_15_Plus
            case "iPhone16,1":                              return .iPhone_15_Pro
            case "iPhone16,2":                              return .iPhone_15_Pro_Max
            default:                                        return .unknown
        }
    }
    
    /// Returns current device name in readable format.
    /// Compatible only with iPhones.
    var iPhoneModelText: String {
        iPhoneModelEnum.rawValue.replacingOccurrences(of: "_", with: " ")
    }
}
