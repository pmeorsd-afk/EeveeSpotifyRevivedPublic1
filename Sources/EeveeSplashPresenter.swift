import UIKit

final class EeveeSplashPresenter {
    
    static func show() {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            // נסה שוב אחרי 0.5 שניות אם ה-window עדיין לא מוכן
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { show() }
            return
        }
        
        let splash = EeveeSplashController()
        splash.modalPresentationStyle = .overFullScreen
        splash.modalTransitionStyle = .crossDissolve
        
        // מצא את ה-VC הכי עליון להצגה
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        topVC.present(splash, animated: false)
    }
}

// MARK: - Splash Controller

final class EeveeSplashController: UIViewController {
    
    private let container = UIView()
    private var dotTimer: Timer?
    private var dots: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
        animateDots()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
            self?.animateOut()
        }
    }
    
    // MARK: - Background
    
    private func setupGradient() {
        let grad = CAGradientLayer()
        grad.frame = view.bounds
        grad.colors = [
            UIColor(red: 0.04, green: 0.04, blue: 0.04, alpha: 1).cgColor,
            UIColor(red: 0.0,  green: 0.12, blue: 0.05, alpha: 1).cgColor,
            UIColor(red: 0.0,  green: 0.0,  blue: 0.0,  alpha: 1).cgColor,
        ]
        grad.locations = [0, 0.5, 1]
        view.layer.insertSublayer(grad, at: 0)
    }
    
    // MARK: - UI
    
    private func setupUI() {
        // Container
        container.translatesAutoresizingMaskIntoConstraints = false
        container.alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.82, y: 0.82)
        view.addSubview(container)
        
        // Icon
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.layer.cornerRadius = 22
        icon.clipsToBounds = true
        icon.image = UIImage(named: "AppIcon") ?? spotifyIcon()
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        // Glow under icon
        let glow = UIView()
        glow.backgroundColor = UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 0.25)
        glow.layer.cornerRadius = 50
        glow.translatesAutoresizingMaskIntoConstraints = false
        
        // Title
        let title = makeLabel("EeveeSpotify", size: 30, weight: .bold, alpha: 1.0)
        
        // Subtitle
        let subtitle = makeLabel("Enhanced Spotify Experience", size: 15, weight: .medium, alpha: 0.65)
        
        // Divider
        let divider = UIView()
        divider.backgroundColor = UIColor(white: 1, alpha: 0.12)
        divider.translatesAutoresizingMaskIntoConstraints = false
        
        // Credit
        let credit = makeLabel("by pmeorsd-afk", size: 13, weight: .regular, alpha: 0.5)
        
        // Version
        let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let versionLabel = makeLabel("v\(ver)", size: 12, weight: .light, alpha: 0.9)
        versionLabel.textColor = UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 0.9)
        
        // Loading dots
        let dotsStack = UIStackView()
        dotsStack.axis = .horizontal
        dotsStack.spacing = 8
        dotsStack.alignment = .center
        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        
        for _ in 0..<3 {
            let d = UIView()
            d.backgroundColor = UIColor(white: 1, alpha: 0.25)
            d.layer.cornerRadius = 4
            d.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                d.widthAnchor.constraint(equalToConstant: 8),
                d.heightAnchor.constraint(equalToConstant: 8)
            ])
            dotsStack.addArrangedSubview(d)
            dots.append(d)
        }
        
        // Add to container
        [glow, icon, title, subtitle, divider, credit, versionLabel, dotsStack].forEach {
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Container
            container.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            container.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            // Glow
            glow.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            glow.topAnchor.constraint(equalTo: container.topAnchor),
            glow.widthAnchor.constraint(equalToConstant: 100),
            glow.heightAnchor.constraint(equalToConstant: 100),
            
            // Icon
            icon.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: glow.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 90),
            icon.heightAnchor.constraint(equalToConstant: 90),
            
            // Title
            title.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            title.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 20),
            
            // Subtitle
            subtitle.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            
            // Divider
            divider.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            divider.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 16),
            divider.widthAnchor.constraint(equalToConstant: 140),
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            // Credit
            credit.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            credit.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 10),
            
            // Version
            versionLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            versionLabel.topAnchor.constraint(equalTo: credit.bottomAnchor, constant: 4),
            
            // Dots
            dotsStack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            dotsStack.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 28),
            dotsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
    }
    
    // MARK: - Helpers
    
    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, alpha: CGFloat) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = UIColor(white: 1, alpha: alpha)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }
    
    // Fallback אם אין AppIcon — מצייר עיגול ירוק עם אות E
    private func spotifyIcon() -> UIImage? {
        let size = CGSize(width: 90, height: 90)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1).cgColor)
        ctx.fillEllipse(in: CGRect(origin: .zero, size: size))
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 48),
            .foregroundColor: UIColor.black
        ]
        let str = NSAttributedString(string: "E", attributes: attrs)
        let strSize = str.size()
        str.draw(at: CGPoint(x: (size.width - strSize.width) / 2,
                             y: (size.height - strSize.height) / 2))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - Animations
    
    private func animateIn() {
        UIView.animate(
            withDuration: 0.55,
            delay: 0,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.4,
            options: .curveEaseOut
        ) {
            self.container.alpha = 1
            self.container.transform = .identity
        }
    }
    
    private func animateDots() {
        var idx = 0
        let green = UIColor(red: 0.11, green: 0.73, blue: 0.33, alpha: 1)
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.38, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            for (i, d) in self.dots.enumerated() {
                UIView.animate(withDuration: 0.2) {
                    d.backgroundColor = i == idx ? green : UIColor(white: 1, alpha: 0.25)
                    d.transform = i == idx
                        ? CGAffineTransform(scaleX: 1.5, y: 1.5)
                        : .identity
                }
            }
            idx = (idx + 1) % self.dots.count
        }
    }
    
    private func animateOut() {
        dotTimer?.invalidate()
        dotTimer = nil
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn) {
            self.container.alpha = 0
            self.container.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        } completion: { _ in
            self.dismiss(animated: false)
        }
    }
}
