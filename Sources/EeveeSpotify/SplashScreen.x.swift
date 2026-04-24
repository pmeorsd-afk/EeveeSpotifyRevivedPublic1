import Orion
import UIKit

// MARK: - Splash Screen Handler

class SplashScreenHandler: NSObject {
    static let shared = SplashScreenHandler()
    private static let dismissedKey = "SplashScreenDismissed"
    private var hasShown = false
    private weak var splashView: UIView?

    func showSplash(in window: UIWindow) {
        // If user already dismissed the splash once, never show again
        guard !UserDefaults.standard.bool(forKey: SplashScreenHandler.dismissedKey) else { return }
        guard !hasShown else { return }
        hasShown = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            self.buildAndPresent(in: window)
        }
    }

    private func buildAndPresent(in window: UIWindow) {
        let splash = UIView(frame: window.bounds)
        splash.backgroundColor = UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)
        splash.alpha = 0
        splash.tag = 999111
        self.splashView = splash

        // ── Scroll view for content ──
        let scrollView = UIScrollView(frame: splash.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.showsVerticalScrollIndicator = false
        splash.addSubview(scrollView)

        // ── Content container ──
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // ── Title: ברוכים הבאים 👋 ──
        let titleLabel = UILabel()
        titleLabel.text = "ברוכים הבאים 👋"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        // ── Subtitle: Credit ──
        let subtitleLabel = UILabel()
        subtitleLabel.text = "אפליקציות פרוצות לאייפון ❄️"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = UIColor(white: 0.7, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(subtitleLabel)

        // ── Logo image ──
        let logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(logoImageView)

        // Load logo from bundle using existing BundleHelper
        logoImageView.image = BundleHelper.shared.uiImage("splash_logo")

        // ── Heart emoji ──
        let heartLabel = UILabel()
        heartLabel.text = "❤️"
        heartLabel.font = UIFont.systemFont(ofSize: 40)
        heartLabel.textAlignment = .center
        heartLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(heartLabel)

        // ── Telegram button ──
        let telegramButton = UIButton(type: .system)
        telegramButton.setTitle("הטלגרם שלנו 👾", for: .normal)
        telegramButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        telegramButton.setTitleColor(.white, for: .normal)
        telegramButton.backgroundColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0) // Bright blue
        telegramButton.layer.cornerRadius = 14
        telegramButton.clipsToBounds = true
        telegramButton.translatesAutoresizingMaskIntoConstraints = false
        telegramButton.addTarget(self, action: #selector(openTelegram), for: .touchUpInside)
        contentView.addSubview(telegramButton)

        // ── Close button ──
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("סגירה", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.backgroundColor = UIColor(red: 1.0, green: 0.22, blue: 0.22, alpha: 1.0) // Red
        closeButton.layer.cornerRadius = 14
        closeButton.clipsToBounds = true
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeSplash), for: .touchUpInside)
        contentView.addSubview(closeButton)

        // ── Layout constraints ──
        let padding: CGFloat = 30

        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),

            // Logo
            logoImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),

            // Heart
            heartLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 25),
            heartLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            // Telegram button
            telegramButton.topAnchor.constraint(greaterThanOrEqualTo: heartLabel.bottomAnchor, constant: 40),
            telegramButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            telegramButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            telegramButton.heightAnchor.constraint(equalToConstant: 52),

            // Close button
            closeButton.topAnchor.constraint(equalTo: telegramButton.bottomAnchor, constant: 12),
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            closeButton.heightAnchor.constraint(equalToConstant: 52),
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),
        ])

        // Push buttons down towards the bottom using a low-priority constraint
        let bottomPush = telegramButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: window.bounds.height - 200)
        bottomPush.priority = .defaultLow
        bottomPush.isActive = true

        // ── Add to window and animate ──
        window.addSubview(splash)
        splash.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        UIView.animate(withDuration: 0.35) {
            splash.alpha = 1
        }

        // Subtle heart pulse animation
        UIView.animate(
            withDuration: 1.2,
            delay: 0.5,
            options: [.repeat, .autoreverse, .allowUserInteraction],
            animations: {
                heartLabel.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            }
        )
    }

    @objc private func openTelegram() {
        if let url = URL(string: "https://t.me/IL_Apk") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc private func closeSplash() {
        guard let splash = self.splashView else { return }
        // Mark as permanently dismissed
        UserDefaults.standard.set(true, forKey: SplashScreenHandler.dismissedKey)
        UIView.animate(withDuration: 0.3, animations: {
            splash.alpha = 0
        }) { _ in
            splash.removeFromSuperview()
        }
    }
}

// MARK: - UIWindow Hook to trigger splash screen

class SplashScreenWindowHook: ClassHook<UIWindow> {
    func makeKeyAndVisible() {
        orig.makeKeyAndVisible()
        SplashScreenHandler.shared.showSplash(in: target)
    }
}
