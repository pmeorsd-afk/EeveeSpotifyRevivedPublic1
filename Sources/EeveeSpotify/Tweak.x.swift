import Orion
import EeveeSpotifyC
import UIKit

// MARK: - Handler
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
        btnTel.backgroundColor = UIColor.systemBlue
        btnTel.layer.cornerRadius = 15
        btnTel.addTarget(AviSplashHandler.shared, action: #selector(AviSplashHandler.openTelegram), for: .touchUpInside)
        splash.addSubview(btnTel)

        let btnClose = UIButton(frame: CGRect(x: 40, y: splash.frame.height - 85, width: splash.frame.width - 80, height: 50))
        btnClose.setTitle("Close", for: .normal)
        btnClose.backgroundColor = .systemRed
        btnClose.layer.cornerRadius = 15
        btnClose.addTarget(AviSplashHandler.shared, action: #selector(AviSplashHandler.dismiss), for: .touchUpInside)
        splash.addSubview(btnClose)

        UIView.animate(withDuration: 0.5) {
            splash.alpha = 1
        }
    }
}

// MARK: - Hook App Launch
class AppDelegateHook: ClassHook<UIApplication> {
    func applicationDidFinishLaunching(_ application: UIApplication) {
        orig.applicationDidFinishLaunching(application)
        showAviSplash()
    }
}

// MARK: - Tweak Entry
struct EeveeSpotify: Tweak {
    init() {
        AppDelegateHook().activate()

        UserDefaults.hasPatchedBootstrap = false
        BasePremiumPatchingGroup().activate()
        NonIOS14PremiumPatchingGroup().activate()
        LatestPremiumPatchingGroup().activate()
        UniversalSettingsIntegrationProfileGroup().activate()
        UniversalSettingsIntegrationSettingsVCGroup().activate()
    }
}
