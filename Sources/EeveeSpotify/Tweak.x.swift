import Orion
import EeveeSpotifyC
import UIKit
import Foundation
import ObjectiveC.runtime

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
    }
    else if EeveeSpotify.hookTarget == .v91 {
        NonIOS14PremiumPatchingGroup().activate()
        let trackRowsSel = Selector(("initWithViewURI:onDemandSet:onDemandTrialService:trackRowsEnabled:productState:"))
        if UIView.instancesRespond(to: trackRowsSel) {
            V91PremiumPatchingGroup().activate()
        }
    }
    else {
        NonIOS14PremiumPatchingGroup().activate()
        
        if EeveeSpotify.hookTarget == .lastAvailableiOS15 {
            IOS14And15PremiumPatchingGroup().activate()
        }
        else {
            LatestPremiumPatchingGroup().activate()
        }
    }
}

func activateSessionLogoutProtection(minimal: Bool) {
    func log(_ msg: String) {
        NSLog("[EeveeSpotify][SessionProtect] %@", msg)
    }

    @inline(__always)
    func classHasInstanceMethod(_ cls: AnyClass, _ sel: Selector) -> Bool {
        return class_getInstanceMethod(cls, sel) != nil
    }

    if minimal {
        if let cls = NSClassFromString("NSURLSessionTask"), classHasInstanceMethod(cls, #selector(URLSessionTask.resume)) {
            SessionLogoutNetworkHookGroup().activate()
            log("Activated URLSessionTask hooks (minimal)")
        } else {
            log("Skipped URLSessionTask hooks (missing selector)")
        }
        return
    }

    if let cls = NSClassFromString("SPTAuthSessionImplementation") {
        let required: [Selector] = [
            Selector(("logout")),
            Selector(("logoutWithReason:")),
            Selector(("callSessionDidLogoutOnDelegateWithReason:")),
            Selector(("logWillLogoutEventWithLogoutReason:")),
            Selector(("destroy")),
        ]
        let ok = required.allSatisfy { classHasInstanceMethod(cls, $0) }
        if ok {
            SessionLogoutAuthHookGroup().activate()
            log("Activated auth hooks")
        } else {
            log("Skipped auth hooks (missing selector)")
        }
    } else {
        log("Skipped auth hooks (missing class SPTAuthSessionImplementation)")
    }

    if let cls = NSClassFromString("_TtC24Connectivity_SessionImpl18SessionServiceImpl") {
        let required: [Selector] = [
            Selector(("automatedLogoutThenLogin")),
            Selector(("userInitiatedLogout")),
            Selector(("sessionDidLogout:withReason:")),
        ]
        let ok = required.allSatisfy { classHasInstanceMethod(cls, $0) }
        if ok {
            SessionLogoutConnectivityHookGroup().activate()
            log("Activated connectivity hooks")
        } else {
            log("Skipped connectivity hooks (missing selector)")
        }
    } else {
        log("Skipped connectivity hooks (missing class SessionServiceImpl)")
    }

    if let cls = NSClassFromString("ARTWebSocketTransport") {
        let required: [Selector] = [
            Selector(("webSocket:didReceiveMessage:")),
            Selector(("webSocket:didFailWithError:")),
        ]
        let ok = required.allSatisfy { classHasInstanceMethod(cls, $0) }
        if ok {
            SessionLogoutAblyHookGroup().activate()
            log("Activated Ably hooks")
        } else {
            log("Skipped Ably hooks (missing selector)")
        }
    } else {
        log("Skipped Ably hooks (missing class ARTWebSocketTransport)")
    }

    if let cls = NSClassFromString("NSURLSessionTask"), classHasInstanceMethod(cls, #selector(URLSessionTask.resume)) {
        SessionLogoutNetworkHookGroup().activate()
        log("Activated URLSessionTask hooks")
    } else {
        log("Skipped URLSessionTask hooks (missing selector)")
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
        NSLog("[EeveeSpotify] Detected Spotify version: \(version)")
        switch version {
        case "9.0.48":
            return .lastAvailableiOS15
        case "8.9.8":
            return .lastAvailableiOS14
        case _ where version.contains("9.1"):
            return .v91
        default:
            return .latest
        }
    }
    
    init() {
        eeveeBreadcrumb("Tweak init() entered")
        UserDefaults.hasPatchedBootstrap = false

        if eeveeEnvFlag("EEVEE_DISABLE_ALL") {
            eeveeBreadcrumb("EEVEE_DISABLE_ALL=1 -> returning without hooks")
            return
        }

        if EeveeSpotify.hookTarget == .v91 {
            activateSessionLogoutProtection(minimal: true)
        } else {
            activateSessionLogoutProtection(minimal: false)
        }

        let spotifyVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let spotifyBuild = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? "?"
        let iosVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.current.model

        writeDebugLog("=== EeveeSpotify \(EeveeSpotify.version) (build \(EeveeSpotify.buildNumber)) starting ===")
        writeDebugLog("[INIT] Spotify: \(spotifyVersion) (build \(spotifyBuild))")
        writeDebugLog("[INIT] iOS: \(iosVersion), Device: \(deviceModel)")
        writeDebugLog("[INIT] Hook target: \(EeveeSpotify.hookTarget)")
        writeDebugLog("[INIT] Patch type: \(UserDefaults.patchType)")
        writeDebugLog("[INIT] Lyrics source: \(UserDefaults.lyricsSource)")
        writeDebugLog("[INIT] tweakInitTime: \(tweakInitTime)")

        let hookTargets: [(String, String)] = [
            ("SPTAuthSessionImplementation", "SPTAuthSession"),
            ("_TtC24Connectivity_SessionImpl18SessionServiceImpl", "SessionServiceImpl"),
            ("SPTAuthLegacyLoginControllerImplementation", "LegacyLoginController"),
            ("_TtC24Connectivity_SessionImplP33_831B98CC28223E431E21CD27ADD20AF222OauthAccessTokenBridge", "OauthAccessTokenBridge"),
            ("ARTWebSocketTransport", "AblyWebSocket"),
            ("ARTSRWebSocket", "AblySRWebSocket"),
        ]
        var allFound = true
        for (className, label) in hookTargets {
            if NSClassFromString(className) != nil {
                writeDebugLog("[INIT] \(label) class found")
            } else {
                writeDebugLog("[INIT] MISSING class for \(label): \(className)")
                allFound = false
            }
        }
        if allFound {
            writeDebugLog("[INIT] All \(hookTargets.count) hook targets verified")
        }

        // MARK: - v91 path
        if EeveeSpotify.hookTarget == .v91 {
            
            if UserDefaults.patchType.isPatching {
                PremiumBootstrapGroup().activate()
                writeDebugLog("[INIT] Activated PremiumBootstrapGroup")

                if let hub = NSClassFromString("HUBViewModelBuilderImplementation"),
                   class_getInstanceMethod(hub, Selector(("addJSONDictionary:"))) != nil {
                    PremiumUIHooksGroup().activate()
                } else {
                    writeDebugLog("[INIT] Skipped PremiumUIHooksGroup (missing HUBViewModelBuilderImplementation/addJSONDictionary:)")
                }
            }
            
            let lyricsEnabled = UserDefaults.lyricsSource.isReplacingLyrics
            
            if lyricsEnabled {
                let fullscreenOK: Bool = {
                    if let cls = NSClassFromString("Lyrics_FullscreenElementPageImpl.FullscreenElementViewController") {
                        return class_getInstanceMethod(cls, #selector(UIViewController.viewDidLoad)) != nil
                    }
                    return false
                }()

                let npvOK: Bool = {
                    if let cls = NSClassFromString("NowPlaying_ScrollImpl.NPVScrollViewController") {
                        return class_getInstanceMethod(cls, #selector(UIViewController.viewWillAppear(_:))) != nil
                            && class_getInstanceMethod(cls, #selector(UIViewController.viewWillDisappear(_:))) != nil
                    }
                    return false
                }()

                if fullscreenOK {
                    BaseLyricsGroup().activate()
                } else {
                    writeDebugLog("[INIT] Skipped BaseLyricsGroup (fullscreen VC missing)")
                }

                if npvOK {
                    V91LyricsGroup().activate()
                } else {
                    writeDebugLog("[INIT] Skipped V91LyricsGroup (NPVScrollViewController missing)")
                }
            }
            
            if let cls = NSClassFromString("ProfileSettingsSection"),
               class_getInstanceMethod(cls, Selector(("numberOfRows"))) != nil,
               class_getInstanceMethod(cls, Selector(("didSelectRow:"))) != nil,
               class_getInstanceMethod(cls, Selector(("cellForRow:"))) != nil {

                UniversalSettingsIntegrationProfileGroup().activate()

                if NSClassFromString("SettingsViewController") != nil {
                    UniversalSettingsIntegrationSettingsVCGroup().activate()
                }
                if NSClassFromString("RootSettingsViewController") != nil {
                    UniversalSettingsIntegrationRootSettingsVCGroup().activate()
                }
                UniversalSettingsIntegrationNavGroup().activate()

            } else {
                writeDebugLog("[INIT] Skipped settings integration (ProfileSettingsSection API mismatch)")
            }
            
            NSLog("[EeveeSpotify] Initialization complete for 9.1.x")
            
            // MARK: - Splash Screen (v91) ✅
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                EeveeSplashPresenter.show()
            }
            
            return
        }
        
        // MARK: - כל שאר הגרסאות
        if UserDefaults.experimentsOptions.showInstagramDestination {
            InstgramDestinationGroup().activate()
        }
        
        if UserDefaults.darkPopUps {
            DarkPopUps().activate()
        }
        
        if UserDefaults.patchType.isPatching {
            activatePremiumPatchingGroup()
        }
        
        if UserDefaults.lyricsSource.isReplacingLyrics {
            BaseLyricsGroup().activate()
            LyricsErrorHandlingGroup().activate()
            
            if EeveeSpotify.hookTarget == .latest {
                ModernLyricsGroup().activate()
            }
            else {
                LegacyLyricsGroup().activate()
            }
        }
        
        UniversalSettingsIntegrationProfileGroup().activate()
        UniversalSettingsIntegrationSettingsVCGroup().activate()
        if NSClassFromString("RootSettingsViewController") != nil {
            UniversalSettingsIntegrationRootSettingsVCGroup().activate()
        }
        UniversalSettingsIntegrationNavGroup().activate()
        SettingsIntegrationGroup().activate()
        
        // MARK: - Splash Screen ✅
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            EeveeSplashPresenter.show()
        }
    }
}
