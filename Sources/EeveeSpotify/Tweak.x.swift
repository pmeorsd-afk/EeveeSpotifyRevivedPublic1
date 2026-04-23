import Orion
import EeveeSpotifyC
import UIKit
import Foundation
import ObjectiveC.runtime

// פונקציית עזר להצגת מסך הפתיחה המעוצב
func showAviSplashScreen() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }

        // יצירת רקע שחור על כל המסך
        let splashView = UIView(frame: window.bounds)
        splashView.backgroundColor = .black
        splashView.alpha = 0
        window.addSubview(splashView)

        // הוספת הלוגו מהלינק שלך
        let logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(logoImageView)

        // הורדת הלוגו מהקישור שהבאת
        if let url = URL(string: "https://files.catbox.moe/55j2aa.png") {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        logoImageView.image = image
                    }
                }
            }.resume()
        }

        // טקסט כותרת
        let titleLabel = UILabel()
        titleLabel.text = "נבנה על ידי אפליקציות פרוצות לאייפון!"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        splashView.addSubview(titleLabel)

        // כפתור מעוצב לטלגרם
        let telegramButton = UIButton(type: .system)
        telegramButton.setTitle("כנסו לטלגרם שלנו לעדכונים", for: .normal)
        telegramButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        telegramButton.setTitleColor(.white, for: .normal)
        telegramButton.backgroundColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0) // כחול טלגרם
        telegramButton.layer.cornerRadius = 12
        telegramButton.translatesAutoresizingMaskIntoConstraints = false
        telegramButton.addTarget(Closure {
            if let url = URL(string: "https://t.me/IL_Apk") {
                UIApplication.shared.open(url)
            }
        }, action: #selector(Closure.execute), for: .touchUpInside)
        splashView.addSubview(telegramButton)

        // כפתור סגירה קטן למטה
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("המשך לספוטיפיי", for: .normal)
        closeButton.setTitleColor(.lightGray, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(Closure {
            UIView.animate(withDuration: 0.5, animations: {
                splashView.alpha = 0
            }) { _ in
                splashView.removeFromSuperview()
            }
        }, action: #selector(Closure.execute), for: .touchUpInside)
        splashView.addSubview(closeButton)

        // הגדרת מיקומים (Constraints)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: splashView.centerYAnchor, constant: -50),
            logoImageView.widthAnchor.constraint(equalToConstant: 180),
            logoImageView.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: splashView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: splashView.trailingAnchor, constant: -20),

            telegramButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -20),
            telegramButton.centerXAnchor.constraint(equalTo: splashView.centerXAnchor),
            telegramButton.widthAnchor.constraint(equalToConstant: 280),
            telegramButton.heightAnchor.constraint(equalToConstant: 55),

            closeButton.bottomAnchor.constraint(equalTo: splashView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            closeButton.centerXAnchor.constraint(equalTo: splashView.centerXAnchor)
        ])

        // אנימציית כניסה
        UIView.animate(withDuration: 0.5) {
            splashView.alpha = 1
        }
    }
}

// קלאס עזר לטיפול בלחיצות כפתור
class Closure: NSObject {
    let closure: () -> Void
    init(_ closure: @escaping () -> Void) { self.closure = closure }
    @objc func execute() { closure() }
}

// שאר הקוד המקורי של המוד (מקוצר לצורך ההסבר, אל תמחק את מה ששלחתי לך קודם בחלק הזה)
struct EeveeSpotify: Tweak {
    static let version = "6.6.2"
    
    init() {
        showAviSplashScreen() // קריאה למסך הפתיחה המעוצב
        // ... (כאן יבוא שאר קוד ה-init המקורי ששלחתי לך קודם)
    }
}

// הערה: תעתיק את שאר פונקציות ה-activate וניהול השרתים מהקובץ המלא ששלחתי קודם, 
// פשוט תוודא ששמת את showAviSplashScreen() בתוך ה-init.
