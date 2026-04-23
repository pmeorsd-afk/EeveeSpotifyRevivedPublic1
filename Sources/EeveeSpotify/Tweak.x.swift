import Orion
import EeveeSpotifyC
import UIKit
import Foundation
import ObjectiveC.runtime

// MARK: - Splash Handler
class AviSplashHandler: NSObject {
    static let shared = AviSplashHandler()
    weak var view: UIView?

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

// MARK: - Splash UI
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
        btnTel.backgroundColor = .systemBlue
        btnTel.layer.cornerRadius = 15
        btnTel.addTarget(AviSplashHandler.shared,
                         action: #selector(AviSplashHandler.openTelegram),
                         for: .touchUpInside)
        splash.addSubview(btnTel)

        let btnClose = UIButton(frame: CGRect(x: 40, y: splash.frame.height - 85, width: splash.frame.width - 80, height: 50))
        btnClose.setTitle("Close", for: .normal)
        btnClose.backgroundColor = .systemRed
        btnClose.layer.cornerRadius = 15
        btnClose.addTarget(AviSplashHandler.shared,
                           action: #selector(AviSplashHandler.dismiss),
                           for: .touchUpInside)
        splash.addSubview(btnClose)

        UIView.animate(withDuration: 0.5) {
            splash.alpha = 1
        }
    }
}

// MARK: - Splash Hook
class SplashHook: ClassHook<UIViewController> {
    static var didShow = false

    func viewDidAppear(_ animated: Bool) {
        orig.viewDidAppear(animated)

        if !Self.didShow {
            Self.didShow = true
            showAviSplash()
        }
    }
}

// ================= ORIGINAL CODE =================

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

// ===== (קיצרתי פה בהסבר — כל שאר הקוד שלך נשאר אותו דבר בדיוק) =====

// MARK: - Tweak Entry
struct EeveeSpotify: Tweak {

    init() {

        // 👉 הפעלת הספלאש
        SplashHook().activate()

        // שאר הקוד שלך רגיל
        UserDefaults.hasPatchedBootstrap = false
        BasePremiumPatchingGroup().activate()
        NonIOS14PremiumPatchingGroup().activate()
        LatestPremiumPatchingGroup().activate()
        UniversalSettingsIntegrationProfileGroup().activate()
        UniversalSettingsIntegrationSettingsVCGroup().activate()
    }
}
