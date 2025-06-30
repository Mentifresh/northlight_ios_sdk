import Foundation
import UIKit

public struct DeviceInfo: Codable {
    let model: String
    let osVersion: String
    let appVersion: String
    let screenResolution: String
    let locale: String
    let freeMemory: String?
    let batteryLevel: Float?
    let networkType: String?
    
    enum CodingKeys: String, CodingKey {
        case model
        case osVersion = "os_version"
        case appVersion = "app_version"
        case screenResolution = "screen_resolution"
        case locale
        case freeMemory = "free_memory"
        case batteryLevel = "battery_level"
        case networkType = "network_type"
    }
    
    static func current(includeBugReportInfo: Bool = false) -> DeviceInfo {
        let device = UIDevice.current
        let screen = UIScreen.main
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        
        var freeMemory: String? = nil
        var batteryLevel: Float? = nil
        var networkType: String? = nil
        
        if includeBugReportInfo {
            freeMemory = DeviceInfoHelper.getFreeMemory()
            device.isBatteryMonitoringEnabled = true
            batteryLevel = device.batteryLevel >= 0 ? device.batteryLevel : nil
            device.isBatteryMonitoringEnabled = false
            networkType = DeviceInfoHelper.getNetworkType()
        }
        
        return DeviceInfo(
            model: DeviceInfoHelper.getDeviceModel(),
            osVersion: device.systemVersion,
            appVersion: appVersion,
            screenResolution: "\(Int(screen.bounds.width * screen.scale))x\(Int(screen.bounds.height * screen.scale))",
            locale: Locale.current.identifier,
            freeMemory: freeMemory,
            batteryLevel: batteryLevel,
            networkType: networkType
        )
    }
}