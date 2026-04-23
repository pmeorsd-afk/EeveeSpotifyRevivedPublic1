import Orion
import EeveeSpotifyC
import UIKit
import Foundation
import ObjectiveC.runtime

// MARK: - Splash Screen Logic
func showAviSplashScreen() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }

        let splashView = UIView(frame: window.bounds)
        splashView.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        splashView.alpha = 0
        window.addSubview(splashView)

        let logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(logoImageView)

        if let url = URL(string: "https://files.catbox.moe/55j2aa.png") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async { logoImageView.image = image }
                }
            }.resume()
        }

        let titleLabel = UILabel()
        titleLabel.text = "Welcome 👋"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Cracked By Avi Miara ❄️"
        subtitleLabel.textColor = .lightGray
        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(subtitleLabel)

        let telegramButton = UIButton(type: .system)
        telegramButton.setTitle("My Telegram 👾", for: .normal)
        telegramButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        telegramButton.setTitleColor(.white, for: .normal)
        telegramButton.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
        telegramButton.layer.cornerRadius = 12
        telegramButton.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(telegramButton)

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor(red: 1.0, green: 0.23, blue: 0.19, alpha: 1.0)
        closeButton.layer.cornerRadius = 12
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: splashView.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),

            logoImageView.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: splashView.centerYAnchor, constant: -20),
            logoImageView.widthAnchor.constraint(equalToConstant: 150),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),

            closeButton.bottomAnchor.constraint(equalTo: splashView.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            closeButton.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalTo: splashView.widthAnchor, multiplier: 0.8),
            closeButton.heightAnchor.constraint(equalToConstant: 50),

            telegramButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -15),
            telegramButton.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            telegramButton.widthAnchor.constraint(equalTo: splashView.widthAnchor, multiplier: 0.8),
            telegramButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        telegramButton.addTarget(ButtonHandler.shared, action: #selector(ButtonHandler.openTelegram), for: .touchUpInside)
        closeButton.addTarget(ButtonHandler.shared, action: #selector(ButtonHandler.dismissSplash), for: .touchUpInside)
        ButtonHandler.shared.viewToDismiss = splashView

        UIView.animate(withDuration: 0.5) { splashView.alpha = 1 }
    }
}

class ButtonHandler: NSObject {
    static let shared = ButtonHandler()
    var viewToDismiss: UIView?
    @objc func openTelegram() { if let url = URL(string: "https://t.me/IL_Apk") { UIApplication.shared.open(url) } }
    @objc func dismissSplash() { UIView.animate(withDuration: 0.4, animations: { self.viewToDismiss?.alpha = 0 }) { _ in self.viewToDismiss?.removeFromSuperview() } }
}

// MARK: - Tweak Core
struct EeveeSpotify: Tweak {
    static let version = "6.6.2"
    init() {
        showAviSplashScreen()
        UserDefaults.hasPatchedBootstrap = false
        BasePremiumPatchingGroup().activate()
        NonIOS14PremiumPatchingGroup().activate()
        LatestPremiumPatchingGroup().activate()
        UniversalSettingsIntegrationProfileGroup().activate()
        UniversalSettingsIntegrationSettingsVCGroup().activate()
        UniversalSettingsIntegrationNavGroup().activate()
    }
}
