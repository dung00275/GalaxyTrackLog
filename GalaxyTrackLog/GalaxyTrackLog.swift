//
//  GalaxyTrackLog.swift
//  GalaxyTrackLog
//
//  Created by Dung Vu on 05/04/2021.
//

import UIKit
import FirebaseAnalytics

// MARK: - App Info
open class Device {
    public static func modelName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "AudioAccessory5,1":                       return "HomePod mini"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }
}

struct AppConfigure: Codable {
    let appName:  String
    let appBundle: String
    let appVersion: String
    let shortVersion: String
    let deviceID = UIDevice.current.identifierForVendor?.uuidString
    let platform = "IOS"
    let deviceModel = UIDevice.current.model
    let deviceType: String = {
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            return "tablet"
        case  .phone:
            return "mobile"
        default:
            return "none"
        }
    }()
    let versionCode = UIDevice.current.systemVersion
    let iOSSDK =  UIDevice.current.systemName
    let language = Locale.current.identifier
    let scale = UIScreen.main.scale
    let screenDensity: CGFloat = {
        let scale = UIScreen.main.scale
        let dpi: CGFloat
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            dpi = 132 * scale
        case .phone:
            dpi = 163 * scale
        default:
            dpi = 160 * scale
        }
        return dpi
    }()
    
    var params: [String: Any] {
        var params: [String: Any] = [:]
        params["DeviceID"] = deviceID
        params["Platform"] = platform
        params["DeviceManufacturer"] = "APPLE"
        params["DeviceModel"] = Device.modelName() //deviceModel
        params["DeviceType"] = deviceType
        params["VersionApp"] = shortVersion
        params["PackageName"] = appBundle
        params["BuildVersion"] = appVersion
        params["VersionOS"] = "\(iOSSDK) \(versionCode)"
        params["DeviceDensity"] = "\(scale)"
        params["Language"] = language
        params["Country"] = Locale.current.regionCode
        return params
    }
    
    enum CodingKeys: String, CodingKey {
        case appName  = "CFBundleDisplayName"
        case appBundle = "CFBundleIdentifier"
        case appVersion = "CFBundleVersion"
        case shortVersion = "CFBundleShortVersionString"
    }
}

// MARK: - Utils
extension Dictionary {
    static func +=(lhs: inout Self, rhs: Self) {
        rhs.forEach { (item) in
            lhs[item.key] = item.value
        }
    }
    
    static func +=(lhs: inout Self, rhs: Self?) {
        rhs?.forEach { (item) in
            lhs[item.key] = item.value
        }
    }
}

extension Date {
    func string(format: String, identifier: String = "en_US_POSIX") -> String {
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: identifier)
        dateFormater.dateFormat = format
        return dateFormater.string(from: self)
    }
}

// MARK: - Main
@objcMembers
public final class GalaxyTrackLog: NSObject {
    public static let shared = GalaxyTrackLog()
    
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.galaxy.tracklog")
        configuration.allowsCellularAccess = true
        configuration.waitsForConnectivity = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    private let app: AppConfigure
    
    /// Path api for up log
    public var urlUpload: String?
    public var sessionID: String?
    public var userID: String = "anonymous" {
        didSet {
            Analytics.setUserID(userID)
        }
    }
    
    /// firebase ID:  FID. ref: https://firebase.google.com/docs/projects/manage-installations
    public var firebaseID: String?
    private var url: URL {
        guard let path = urlUpload, let url = URL(string: path)  else {
            fatalError("Please check url upload!!!.")
        }
        return url
    }
    
    private lazy var queue = DispatchQueue(label: "com.galaxy.excuteLog")
    
    private override init() {
        do {
            guard let file = Bundle.main.url(forResource: "Info", withExtension: "plist") else {
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: [NSLocalizedDescriptionKey: "No file Info.plist."])
            }
            let data = try Data(contentsOf: file)
            let decoder = PropertyListDecoder()
            app = try decoder.decode(AppConfigure.self, from: data)
            super.init()
        } catch {
            fatalError("Check : \(error.localizedDescription)!!!")
        }
    }
    
    /// Send event
    /// - Parameter params: json object send to server
    private func logEvent(name: String, params: [String: Any]?) {
        queue.async { [unowned self] in
            let p = params
            guard let sessionID = self.sessionID,
                  let firebaseID = self.firebaseID else {
                fatalError("Check sessionID, firebaseID !!!")
            }
            var params = self.app.params
            params["EventTime"] = Date().timeIntervalSince1970 //.string(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            params["SessionID"] = sessionID
            params["FID"] = firebaseID
            params["UserID"] = self.userID
            params += p
            guard JSONSerialization.isValidJSONObject(params) else {
                return
            }
            
            defer {
                Analytics.logEvent(name, parameters: params)
            }
            
            do {
                let data = try JSONSerialization.data(withJSONObject: params, options: [])
                var request = URLRequest(url: url)
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpMethod = "POST"
                request.httpBody = data
                let task = session.dataTask(with: request)
                task.resume()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Send event
    /// - Parameter params: json object send to server
    public static func log(name: String, params: [String: Any]?) {
        GalaxyTrackLog.shared.logEvent(name: name, params: params)
    }
    
    
    /// Send Encodable object to server
    /// - Parameter value: object
    /// - Throws: error encode
    public static func log<T: Encodable>(name: String, value: T) throws  {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        log(name: name, params: json)
    }
}

// MARK: - Delegate
extension GalaxyTrackLog: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else {
            return
        }
        print(error.localizedDescription)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let res = String(data: data, encoding: .utf8)
        print("Result: \(res ?? "")")
    }
}
