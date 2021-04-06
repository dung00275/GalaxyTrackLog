//
//  GalaxyTrackLog.swift
//  GalaxyTrackLog
//
//  Created by Dung Vu on 05/04/2021.
//

import UIKit

// MARK: - App Info
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
        params["DeviceModel"] = deviceModel
        params["DeviceType"] = deviceType
        params["VersionApp"] = appBundle
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
    func string(format: String, identifier: String = "en_US") -> String {
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
    public var userID: String = "anonymous"
    
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
    private func log(params: [String: Any]?) {
        queue.async { [unowned self] in
            let p = params
            guard let sessionID = self.sessionID,
                  let firebaseID = self.firebaseID else {
                fatalError("Check sessionID, firebaseID !!!")
            }
            var params = self.app.params
            params["EventTime"] = Date().string(format: "yyyy-MM-dd**hh:mm:ss.sTZD").replacingOccurrences(of: "**", with: "T")
            params["SessionID"] = sessionID
            params["FID"] = firebaseID
            params["UserID"] = self.userID
            params += p
            guard JSONSerialization.isValidJSONObject(params) else {
                return
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
    public static func log(params: [String: Any]?) {
        GalaxyTrackLog.shared.log(params: params)
    }
    
    
    /// Send Encodable object to server
    /// - Parameter value: object
    /// - Throws: error encode
    public static func log<T: Encodable>(value: T) throws  {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        log(params: json)
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
