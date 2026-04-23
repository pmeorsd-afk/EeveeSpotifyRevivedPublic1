import Orion
import EeveeSpotifyC
import UIKit
import Foundation
import ObjectiveC.runtime

// MARK: - Avi Splash View Controller (הדרך הבטוחה והרשמית להציג מסך)
class AviSplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // צבע רקע
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        
        // כותרת
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 100, width: view.frame.width, height: 40))
        titleLabel.text = "Welcome 👋"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 30)
        titleLabel.textAlignment = .center
        titleLabel.autoresizingMask = [.flexibleWidth]
        view.addSubview(titleLabel)

        // תת כותרת
        let subLabel = UILabel(frame: CGRect(x: 0, y: 145, width: view.frame.width, height: 30))
        subLabel.text = "Cracked By Avi Miara ❄️"
        subLabel.textColor = .lightGray
        subLabel.font = .systemFont(ofSize: 18)
        subLabel.textAlignment = .center
        subLabel.autoresizingMask = [.flexibleWidth]
        view.addSubview(subLabel)

        // לוגו
        let logo = UIImageView(frame: CGRect(
            x: (view.frame.width - 150) / 2,
            y: (view.frame.height - 150) / 2,
            width: 150,
            height: 150
        ))
        logo.contentMode = .scaleAspectFit
        logo.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        view.addSubview(logo)

        // הורדת התמונה מהאינטרנט בצורה בטוחה
        if let url = URL(string: "https://files.catbox.moe/55j2aa.png") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    logo.image = image
                }
            }.resume()
        }

        // כפתור טלגרם
        let btnTel = UIButton(frame: CGRect(x: 40, y: view.frame.height - 160, width: view.frame.width - 80, height: 50))
        btnTel.setTitle("My Telegram 👾", for: .normal)
        btnTel.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        btnTel.layer.cornerRadius = 15
        btnTel.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        btnTel.addTarget(self, action: #selector(openTelegram), for: .touchUpInside)
        view.addSubview(btnTel)

        // כפתור סגירה
        let btnClose = UIButton(frame: CGRect(x: 40, y: view.frame.height - 90, width: view.frame.width - 80, height: 50))
        btnClose.setTitle("Close", for: .normal)
        btnClose.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        btnClose.layer.cornerRadius = 15
        btnClose.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        btnClose.addTarget(self, action: #selector(dismissSplash), for: .touchUpInside)
        view.addSubview(btnClose)
    }
    
    @objc func openTelegram() {
        if let url = URL(string: "https://t.me/IL_Apk") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func dismissSplash() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Splash Manager
class AviSplashManager: NSObject {
    static let shared = AviSplashManager()

    @objc func appDidLaunch() {
        // מחכים 1.5 שניות שספוטיפיי תירגע ותטען את עצמה
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.presentSplashSafely()
        }
    }

    func presentSplashSafely() {
        // מוצאים את המסך העליון ביותר של האפליקציה בצורה בטוחה
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else { return }
        
        var topController = rootVC
        while let presented = topController.presentedViewController {
            topController = presented
        }
        
        // יצירת המסך המעוצב שלנו
        let splashVC = AviSplashViewController()
        splashVC.modalPresentationStyle = .overFullScreen // מכסה הכל
        splashVC.modalTransitionStyle = .crossDissolve // אנימציה של התבהרות עדינה
        
        // הצגה בטוחה על המסך
        topController.present(splashVC, animated: true, completion: nil)
    }
}

// MARK: - Original EeveeSpotify Logic
func writeDebugLog(_ message: String) {
    NSLog("[EeveeSpotify] %@", message)
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
    @inline(__always) func classHasInstanceMethod(_ cls: AnyClass, _ sel: Selector) -> Bool {
        return class_getInstanceMethod(cls, sel) != nil
    }

    if minimal {
        if let cls = NSClassFromString("NSURLSessionTask"), classHasInstanceMethod(cls, #selector(URLSessionTask.resume)) {
            SessionLogoutNetworkHookGroup().activate()
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

@inline(__always) func eeveeEnvFlag(_ name: String) -> Bool {
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
        // תחילת העבודה של המסך שלנו
        NotificationCenter.default.addObserver(
            AviSplashManager.shared,
            selector: #selector(AviSplashManager.appDidLaunch),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )

        UserDefaults.hasPatchedBootstrap = false
        if eeveeEnvFlag("EEVEE_DISABLE_ALL") { return }

        if EeveeSpotify.hookTarget == .v91 {
            activateSessionLogoutProtection(minimal: true)
            if UserDefaults.patchType.isPatching { PremiumBootstrapGroup().activate() }
            if UserDefaults.lyricsSource.isReplacingLyrics {
                BaseLyricsGroup().activate()
                V91LyricsGroup().activate()
            }
            UniversalSettingsIntegrationProfileGroup().activate()
            UniversalSettingsIntegrationNavGroup().activate()
            return
        }
        
        activateSessionLogoutProtection(minimal: false)
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
