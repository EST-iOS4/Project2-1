import UIKit
import NMapsMap

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // Info.plist -> $(NaverMapNcpKeyId) -> xcconfig에서 주입
    if let ncpKeyId = Bundle.main.object(forInfoDictionaryKey: "NaverMapNcpKeyId") as? String,
       !ncpKeyId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      NMFAuthManager.shared().ncpKeyId = ncpKeyId
    } else {
      assertionFailure("NaverMapNcpKeyId is missing. Please set it in xcconfig and Info.plist.")
      // 개발 중 크래시를 원치 않으면 로그만 남기고 넘어가도 됩니다.
      // print("⚠️ NaverMapNcpKeyId is missing.")
    }

    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }
}
