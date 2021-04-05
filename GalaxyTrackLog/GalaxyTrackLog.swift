//
//  GalaxyTrackLog.swift
//  GalaxyTrackLog
//
//  Created by Dung Vu on 05/04/2021.
//

import UIKit

final class AppConfigure: Codable {
    let appName:  String
    let appBundle: String
    let appVersion: String
    let shortVersion: String
    lazy var deviceID = UIDevice.current.identifierForVendor?.uuid
    let platform = "IOS"
    let deviceModel = UIDevice.current.model
    lazy var deviceType: String = {
        let type = UIDevice.current.userInterfaceIdiom
        switch type {
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
    
    var params: [String: Any] {
        var params: [String: Any] = [:]
        params["DeviceID"] = deviceID
        params["Platform"] = platform
        params["DeviceManufacturer"] = "APPLE"
        params["DeviceModel"] = deviceModel
        params["DeviceType"] = deviceType
        params["VersionApp"] = appVersion
        return params
    }
    
    enum CodingKeys: String, CodingKey {
        case appName  = "CFBundleDisplayName"
        case appBundle = "CFBundleIdentifier"
        case appVersion = "CFBundleVersion"
        case shortVersion = "CFBundleShortVersionString"
    }
}

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

@objcMembers
public final class GalaxyTrackLog: NSObject {
    public static let shared = GalaxyTrackLog()
    
    private var session: URLSession?
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
    
    private override init() {
        do {
            guard let file = Bundle.main.url(forResource: "Info", withExtension: "plist") else {
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: [NSLocalizedDescriptionKey: "No file Info.plist."])
            }
            let data = try Data(contentsOf: file)
            let decoder = PropertyListDecoder()
            app = try decoder.decode(AppConfigure.self, from: data)
            super.init()
            let configuration  = URLSessionConfiguration.background(withIdentifier: "com.galaxy.tracklog")
            configuration.allowsCellularAccess =  true
            session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        } catch {
            fatalError("Check : \(error.localizedDescription)!!!")
        }
    }
    
    
    /// Send event
    /// - Parameter params: json object send to server
    public func log(params: [String: Any]?) {
        let p = params
        guard let sessionID = sessionID, let firebaseID = firebaseID else {
            fatalError("Check sessionID, firebaseID !!!")
        }
        var params = app.params
        params["EventTime"] = Date().string(format: "yyyy-MM-dd**hh:mm:ss.sTZD").replacingOccurrences(of: "**", with: "T")
        params["SessionID"] = sessionID
        params["FID"] = firebaseID
        params["UserID"] = userID
        params += p
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = data
            let task = session?.dataTask(with: request)
            task?.resume()
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension GalaxyTrackLog: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error else {
            return
        }
        print(error.localizedDescription)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {}
}
