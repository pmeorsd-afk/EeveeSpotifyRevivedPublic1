import Orion
import EeveeSpotifyC
import UIKit

// MARK: - Helper Class for UI Actions
class AviSplashHandler: NSObject {
    static let shared = AviSplashHandler()
    var view: UIView?

    @objc func openTelegram() {
        if let url = URL(string: "https://t.me/IL_Apk") {
            UIApplication.shared.open(url)
        }
    }

    @objc func dismiss() {
        UIView.animate(withDuration: 0.4, animations: {
            self.view?.alpha = 0
        }) { _ in
            self.view?.removeFromSuperview()
        }
    }
}

// MARK: - Main Splash Function
func showAviSplash() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        guard let window = UIApplication.shared.windows.first else { return }

        let splash = UIView(frame: window.bounds)
        splash.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        splash.alpha = 0
        window.addSubview(splash)
        AviSplashHandler.shared.view = splash

        // Welcome Text
        let title = UILabel()
        title.text = "Welcome 👋"
        title.textColor = .white
        title.font = .boldSystemFont(ofSize: 30)
        title.textAlignment = .center
        title.frame = CGRect(x: 0, y: 100, width: splash.frame.width, height: 40)
        splash.addSubview(title)

        // Subtitle
        let sub = UILabel()
        sub.text = "Cracked By Avi Miara ❄️"
        sub.textColor = .lightGray
        sub.font = .systemFont(ofSize: 18)
        sub.textAlignment = .center
        sub.frame = CGRect(x: 0, y: 145, width: splash.frame.width, height: 30)
        splash.addSubview(sub)

        // Logo
        let logo = UIImageView(frame: CGRect(x: (splash.frame.width - 150) / 2, y: (splash.frame.height - 150) / 2, width: 150, height: 150))
        logo.contentMode = .scaleAspectFit
        splash.addSubview(logo)
        
        if let url = URL(string: "https://files.catbox.moe/55j2aa.png") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let d = data, let img = UIImage(data: d) {
                    DispatchQueue.main.async { logo.image = img }
                }
            }.resume()
        }

        // Telegram Button (Blue)
        let btnTel = UIButton(frame: CGRect(x: 40, y: splash.frame.height - 150, width: splash.frame.width - 80, height: 50))
        btnTel.setTitle("My Telegram 👾", for: .normal)
        btnTel.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
        btnTel.layer.cornerRadius = 15
        btnTel.addTarget(AviSplashHandler.shared, action: #selector(AviSplashHandler.shared.openTelegram), for: .touchUpInside)
        splash.addSubview(btnTel)

        // Close Button (Red)
        let btnClose = UIButton(frame: CGRect(x: 40, y: splash.frame.height - 85, width: splash.frame.width - 80, height: 50))
        btnClose.setTitle("Close", for: .normal)
        btnClose.backgroundColor = .systemRed
        btnClose.layer.cornerRadius = 15
        btnClose.addTarget(AviSplashHandler.shared, action: #selector(AviSplashHandler.shared.dismiss), for: .touchUpInside)
        splash.addSubview(btnClose)

        UIView.animate(withDuration: 0.5) { splash.alpha = 1 }
    }
}

// MARK: - Tweak Core
struct EeveeSpotify: Tweak {
    init() {
        showAviSplash()
        
        // טעינת רכיבי הפריצה הבסיסיים
        UserDefaults.hasPatchedBootstrap = false
        BasePremiumPatchingGroup().activate()
        NonIOS14PremiumPatchingGroup().activate()
        LatestPremiumPatchingGroup().activate()
        UniversalSettingsIntegrationProfileGroup().activate()
        UniversalSettingsIntegrationSettingsVCGroup().activate()
    }
}
