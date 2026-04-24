import Orion
import EeveeSpotifyC
import UIKit
import Foundation
import ObjectiveC.runtime

// MARK: - Avi Splash Manager (Claude's Logic)
final class AviSplashManager {
    static let shared = AviSplashManager()
    private var hasShown = false
    private var splashWindow: UIWindow?

    private init() {}

    func showIfNeeded() {
        guard !hasShown else { return }
        hasShown = true
        presentSplash()
    }

    private func presentSplash() {
        // מציאת החלון הפעיל בצורה בטוחה אחרי שה-UI נרגע
        guard
            let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.presentSplash()
            }
            return
        }

        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.backgroundColor = .clear
        window.rootViewController = AviSplashViewController { [weak self] in
            self?.dismissSplash()
        }
        window.makeKeyAndVisible()
        window.alpha = 0

        UIView.animate(withDuration: 0.4) { window.alpha = 1.0 }

        // שמירה על החלון בזיכרון
        self.splashWindow = window
    }

    private func dismissSplash() {
        UIView.animate(withDuration: 0.35, animations: {
            self.splashWindow?.alpha = 0
        }) { _ in
            self.splashWindow?.isHidden = true
            self.splashWindow = nil
        }
    }
}

// MARK: - Avi Splash View Controller
final class AviSplashViewController: UIViewController {
    private let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(white: 0.05, alpha: 1.0)

        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Welcome 👋"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 32)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        // Subtitle
        let subLabel = UILabel()
        subLabel.text = "Cracked By Avi Miara ❄️"
        subLabel.textColor = .lightGray
        subLabel.font = .systemFont(ofSize: 18)
        subLabel.textAlignment = .center
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subLabel)

        // Logo
        let logo = UIImageView()
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logo)

        // Telegram button
        let btnTel = makeButton(title: "My Telegram 👾",
                                color: UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),
                                action: #selector(openTelegram))

        // Close button
        let btnClose = makeButton(title: "Close",
                                  color: UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0),
                                  action: #selector(closeSplash))

        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: 160),
            logo.heightAnchor.constraint(equalToConstant: 160),

            btnTel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            btnTel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            btnTel.bottomAnchor.constraint(equalTo: btnClose.topAnchor, constant: -12),
            btnTel.heightAnchor.constraint(equalToConstant: 55),

            btnClose.leadingAnchor.constraint(equalTo: btnTel.leadingAnchor),
            btnClose.trailingAnchor.constraint(equalTo: btnTel.trailingAnchor),
            btnClose.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            btnClose.heightAnchor.constraint(equalToConstant: 55),
        ])

        // Async image load
        if let url = URL(string: "https://files.catbox.moe/55j2aa.png") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async { logo.image = image }
            }.resume()
        }
    }

    private func makeButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = color
        btn.titleLabel?.font = .boldSystemFont(ofSize: 19)
        btn.layer.cornerRadius = 16
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(btn)
        return btn
    }

    @objc private func openTelegram() {
        guard let url = URL(string: "https://t.me/IL_Apk") else { return }
        UIApplication.shared.open(url)
    }

    @objc private func closeSplash() {
        onClose()
    }
}

// MARK: - Orion Hook (The Magic)
class RootVCHook: ClassHook<UIViewController> {
    func viewDidAppear(_ animated: Bool) {
        orig.viewDidAppear(animated)

        guard
            self.target.view.window?.isKeyWindow == true,
            self.target.parent == nil
        else { return }

        AviSplashManager.shared.showIfNeeded()
    }
}

// MARK: - Original EeveeSpotify Logic
func writeDebugLog(_ message: String) { NSLog("[EeveeSpotify] %@", message) }

let tweakInitTime: Date = {
    if let existing = getenv("EEVEE_BOOT_TIME"), let interval = Double(String(cString: existing)) { return Date(timeIntervalSince1970: interval) }
    let now = Date()
    setenv("EEVEE_BOOT_TIME", "\(now.timeIntervalSince1970)", 1)
    return now
}()

func exitApplication() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in exit(EXIT_SUCCESS) }
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
    if EeveeSpotify.hookTarget == .lastAvailableiOS14 { IOS14PremiumPatchingGroup().activate() }
    else if EeveeSpotify.hookTarget == .v91 {
        NonIOS14PremiumPatchingGroup().activate()
        let trackRowsSel = Selector(("initWithViewURI:onDemandSet:onDemandTrialService:trackRowsEnabled:productState:"))
        if UIView.instancesRespond(to: trackRowsSel) { V91PremiumPatchingGroup().activate() }
    } else {
        NonIOS14PremiumPatchingGroup().activate()
        if EeveeSpotify.hookTarget == .lastAvailableiOS15 { IOS14And15PremiumPatchingGroup().activate() }
        else { LatestPremiumPatchingGroup().activate() }
    }
}

func activateSessionLogoutProtection(minimal: Bool) {
    @inline(__always) func classHasInstanceMethod(_ cls: AnyClass, _ sel: Selector) -> Bool { return class_getInstanceMethod(cls, sel) != nil }
    if minimal {
        if let cls = NSClassFromString("NSURLSessionTask"), classHasInstanceMethod(cls, #selector(URLSessionTask.resume)) { SessionLogoutNetworkHookGroup().activate() }
        return
    }
    if let cls = NSClassFromString("SPTAuthSessionImplementation") {
        let required: [Selector] = [ Selector(("logout")), Selector(("logoutWithReason:")), Selector(("callSessionDidLogoutOnDelegateWithReason:")), Selector(("logWillLogoutEventWithLogoutReason:")), Selector(("destroy")) ]
        if required.allSatisfy({ classHasInstanceMethod(cls, $0) }) { SessionLogoutAuthHookGroup().activate() }
    }
    if let cls = NSClassFromString("_TtC24Connectivity_SessionImpl18SessionServiceImpl") {
        let required: [Selector] = [ Selector(("automatedLogoutThenLogin")), Selector(("userInitiatedLogout")), Selector(("sessionDidLogout:withReason:")) ]
        if required.allSatisfy({ classHasInstanceMethod(cls, $0) }) { SessionLogoutConnectivityHookGroup().activate() }
    }
    if let cls = NSClassFromString("ARTWebSocketTransport") {
        let required: [Selector] = [ Selector(("webSocket:didReceiveMessage:")), Selector(("webSocket:didFailWithError:")) ]
        if required.allSatisfy({ classHasInstanceMethod(cls, $0) }) { SessionLogoutAblyHookGroup().activate() }
    }
    if let cls = NSClassFromString("NSURLSessionTask"), classHasInstanceMethod(cls, #selector(URLSessionTask.resume)) { SessionLogoutNetworkHookGroup().activate() }
}

@inline(__always) func eeveeEnvFlag(_ name: String) -> Bool {
    guard let v = getenv(name) else { return false }
    return String(cString: v).lowercased() == "1" || String(cString: v).lowercased() == "true"
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
        // (ההוק של קלוד RootVCHook נטען אוטומטית על ידי Orion, אז לא צריך לקרוא לו פה)
        
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
        if NSClassFromString("RootSettingsViewController") != nil { UniversalSettingsIntegrationRootSettingsVCGroup().activate() }
        UniversalSettingsIntegrationNavGroup().activate()
        SettingsIntegrationGroup().activate()
    }
}
