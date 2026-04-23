import Orion
import EeveeSpotifyC
import UIKit
import Foundation
import ObjectiveC.runtime

// MARK: - Avi Splash Screen Handler
class AviSplashHandler: NSObject {
    static let shared = AviSplashHandler()
    weak var view: UIView?

    @objc func appDidLaunch() {
        showAviSplash()
    }

    @objc func openTelegram() {
        guard let url = URL(string: "https://t.me/IL_Apk") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    @objc func dismiss() {
        guard let view = view else { return }
        UIView.animate(withDuration: 0.4, animations: {
            view.alpha = 0
        }) { _ in
            view.removeFromSuperview()
        }
    }
}

func showAviSplash() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let splash = UIView(frame: window.bounds)
        splash.backgroundColor = UIColor(white: 0.1, alpha: 1)
        splash.alpha = 0
        window.addSubview(splash)

        AviSplashHandler.shared.view = splash

        let title = UILabel(frame: CGRect(x: 0, y: 100, width: splash.frame.width, height: 40))
        title.text = "Welcome 👋"
        title.textColor = .white
        title.font = .boldSystemFont(ofSize: 30)
        title.textAlignment = .center
        splash.addSubview(title)

        let sub = UILabel(frame: CGRect(x: 0, y: 145, width: splash.frame.width, height: 30))
        sub.text = "Cracked By Avi Miara ❄️"
        sub.textColor = .lightGray
        sub.font = .systemFont(ofSize: 18)
        sub.textAlignment = .center
        splash.addSubview(sub)

        let logo = UIImageView(frame: CGRect(
            x: (splash.frame.width - 150) / 2,
            y: (splash.frame.height - 150) / 2,
            width: 150,
            height: 150
        ))
        logo.contentMode = .scaleAspectFit
        splash.addSubview(logo)

        if let url = URL(string: "https://files.catbox.moe/55j2aa.png") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    logo.image = image
                }
            }.resume()
        }

        let btnTel = UIButton(frame: CGRect(x: 40, y: splash.frame.height - 150, width: splash.frame.width - 80, height: 50))
        btnTel.setTitle("My Telegram 👾", for: .normal)
        btnTel.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        btnTel.layer.cornerRadius = 15
        btnTel.addTarget(AviSplashHandler.shared, action: #selector(AviSplashHandler.openTelegram), for: .touchUpInside)
        splash.addSubview(btnTel)

        let btnClose = UIButton(frame: CGRect(x: 40, y: splash.frame.height - 85, width: splash.frame.width - 80, height: 50))
        btnClose.setTitle("Close", for: .normal)
        btnClose.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        btnClose.layer.cornerRadius = 15
        btnClose.addTarget(AviSplashHandler.shared, action: #selector(AviSplashHandler.dismiss), for: .touchUpInside)
        splash.addSubview(btnClose)

        UIView.animate(withDuration: 0.5) {
            splash.alpha = 1
        }
    }
}

// MARK: - Original EeveeSpotify Logic
func writeDebugLog(_ message: String) {
    NSLog("[EeveeSpotify] %@", message)
    let logPath = NSTemporaryDirectory() + "eeveespotify_debug.log"
    let timestamp = Date().description
    let logMessage = "[\(timestamp)] \(message)\n"
    if FileManager.default.fileExists(atPath: logPath) {
        if let fileHandle = FileHandle(forWritingAtPath: logPath) {
            fileHandle.seekToEndOfFile()
            if let data = logMessage.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        }
    } else {
        try? logMessage.write(toFile: logPath, atomically: true, encoding: .utf8)
    }
}

let tweakInitTime: Date = {
    if let existing = getenv("EEVEE_BOOT_TIME"),
       let interval = Double(String(cString: existing)) {
        return Date(timeIntervalSince1970: interval)
    }
    let now = Date()
    setenv("EEVEE_BOOT_TIME", "\(now.timeIntervalSince1970)", 1)
    return now
}()

func exitApplication() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
        exit(EXIT_SUCCESS)
    }
}

struct PremiumBootstrapGroup: HookGroup { }
struct PremiumUIHooksGroup: HookGroup { }
struct BasePremiumPatchingGroup: HookGroup { }
struct IOS14PremiumPatchingGroup: HookGroup { }
struct NonIOS14PremiumPatchingGroup: HookGroup { }
struct IOS14And15PremiumPatchingGroup: HookGroup { }
struct V91PremiumPatchingGroup: HookGroup { }
struct LatestPremiumPatchingGroup: HookGroup { }

func activatePremiumPatchingGroup() {
    BasePremiumPatchingGroup().activate()
    if EeveeSpotify.hookTarget == .lastAvailableiOS14 {
        IOS14PremiumPatchingGroup().activate()
    } else if EeveeSpotify.hookTarget == .v91 {
        NonIOS14PremiumPatchingGroup().activate()
        let trackRowsSel = Selector(("initWithViewURI:onDemandSet:onDemandTrialService:trackRowsEnabled:productState:"))
        if UIView.instancesRespond(to: trackRowsSel) {
            V91PremiumPatchingGroup().activate()
        }
    } else {
        NonIOS14PremiumPatchingGroup().activate()
        if EeveeSpotify.hookTarget == .lastAvailableiOS15 {
            IOS14And15PremiumPatchingGroup().activate()
        } else {
            LatestPremiumPatchingGroup().activate()
        }
    }
}

func activateSessionLogoutProtection(minimal: Bool) {
    func log(_ msg: String) { NSLog("[EeveeSpotify][SessionProtect] %@", msg) }
    @inline(__always) func classHasInstanceMethod(_ cls: AnyClass, _ sel: Selector) -> Bool {
        return class_getInstanceMethod(cls, sel) != nil
    }

    if minimal {
        if let cls = NSClassFromString("NSURLSessionTask"), classHasInstanceMethod(cls, #selector(URLSessionTask.resume)) {
            SessionLogoutNetworkHookGroup().activate()
            log("Activated URLSessionTask hooks (minimal)")
        }
        return
    }

    if let cls = NSClassFromString("SPTAuthSessionImplementation") {
        let required: [Selector] = [ Selector(("logout")), Selector(("logoutWithReason:")), Selector(("callSessionDidLogoutOnDelegateWithReason:")), Selector(("logWillLogoutEventWithLogoutReason:")), Selector(("destroy")) ]
        if required.allSatisfy({ classHasInstanceMethod(cls, $0) }) {
            SessionLogoutAuthHookGroup().activate()
        }
    }
    if let cls = NSClassFromString("_TtC24Connectivity_SessionImpl18SessionServiceImpl") {
        let required: [Selector] = [ Selector(("automatedLogoutThenLogin")), Selector(("userInitiatedLogout")), Selector(("sessionDidLogout:withReason:")) ]
        if required.allSatisfy({ classHasInstanceMethod(cls, $0) }) {
            SessionLogoutConnectivityHookGroup().activate()
        }
    }
    if let cls = NSClassFromString("ARTWebSocketTransport") {
        let required: [Selector] = [ Selector(("webSocket:didReceiveMessage:")), Selector(("webSocket:didFailWithError:")) ]
        if required.allSatisfy({ classHasInstanceMethod(cls, $0) }) {
            SessionLogoutAblyHookGroup().activate()
        }
    }
    if let cls = NSClassFromString("NSURLSessionTask"), classHasInstanceMethod(cls, #selector(URLSessionTask.resume)) {
        SessionLogoutNetworkHookGroup().activate()
    }
}

@inline(__always)
func eeveeBreadcrumb(_ label: String) {
    let path = NSTemporaryDirectory() + "eeveespotify_boot.txt"
    let ts = Date().description
    let line = "[\(ts)] \(label)\n"
    if let data = line.data(using: .utf8) {
        if FileManager.default.fileExists(atPath: path), let h = FileHandle(forWritingAtPath: path) {
            h.seekToEndOfFile(); h.write(data); try? h.close()
        } else {
            try? data.write(to: URL(fileURLWithPath: path))
        }
    }
}

@inline(__always)
func eeveeEnvFlag(_ name: String) -> Bool {
    guard let v = getenv(name) else { return false }
    let s = String(cString: v).lowercased()
    return s == "1" || s == "true" || s == "yes" || s == "y"
}

struct EeveeSpotify: Tweak {
    static let version = "6.6.2"
    static let buildNumber = "1"
    
    static var hookTarget: VersionHookTarget {
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        switch version {
        case "9.0.48": return .lastAvailableiOS15
        case "8.9.8": return .lastAvailableiOS14
        case _ where version.contains("9.1"): return .v91
        default: return .latest
        }
    }
    
    init() {
        // האזנה לסיום עליית האפליקציה כדי להקפיץ את המסך המעוצב!
        NotificationCenter.default.addObserver(
            AviSplashHandler.shared,
            selector: #selector(AviSplashHandler.appDidLaunch),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )

        eeveeBreadcrumb("Tweak init() entered")
        UserDefaults.hasPatchedBootstrap = false

        if eeveeEnvFlag("EEVEE_DISABLE_ALL") { return }

        if EeveeSpotify.hookTarget == .v91 {
            activateSessionLogoutProtection(minimal: true)
        } else {
            activateSessionLogoutProtection(minimal: false)
        }

        if EeveeSpotify.hookTarget == .v91 {
            if UserDefaults.patchType.isPatching { PremiumBootstrapGroup().activate() }
            let lyricsEnabled = UserDefaults.lyricsSource.isReplacingLyrics
            if lyricsEnabled {
                BaseLyricsGroup().activate()
                V91LyricsGroup().activate()
            }
            UniversalSettingsIntegrationProfileGroup().activate()
            UniversalSettingsIntegrationNavGroup().activate()
            return
        }
        
        if UserDefaults.experimentsOptions.showInstagramDestination { InstgramDestinationGroup().activate() }
        if UserDefaults.darkPopUps { DarkPopUps().activate() }
        if UserDefaults.patchType.isPatching { activatePremiumPatchingGroup() }
        if UserDefaults.lyricsSource.isReplacingLyrics {
            BaseLyricsGroup().activate()
            LyricsErrorHandlingGroup().activate()
            if EeveeSpotify.hookTarget == .latest { ModernLyricsGroup().activate() }
            else { LegacyLyricsGroup().activate() }
        }
        
        UniversalSettingsIntegrationProfileGroup().activate()
        UniversalSettingsIntegrationSettingsVCGroup().activate()
        if NSClassFromString("RootSettingsViewController") != nil {
            UniversalSettingsIntegrationRootSettingsVCGroup().activate()
        }
        UniversalSettingsIntegrationNavGroup().activate()
        SettingsIntegrationGroup().activate()
    }
}
