import UIKit
import SwiftyDropbox

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 드롭박스 초기화
        DropboxClientsManager.setupWithAppKey("1em5fe2y4ez7g4k")
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // 드롭박스 OAuth 콜백 처리
        let oauthCompletion: DropboxOAuthCompletion = { authResult in
            if let authResult = authResult {
                switch authResult {
                case .success:
                    print("드롭박스 인증 성공!")
                    NotificationCenter.default.post(name: NSNotification.Name("DropboxAuthSuccess"), object: nil)
                case .cancel:
                    print("드롭박스 인증 취소")
                case .error(_, let description):
                    print("드롭박스 인증 오류: \(description ?? "")")
                }
            }
        }
        
        let canHandleUrl = DropboxClientsManager.handleRedirectURL(url, includeBackgroundClient: false, completion: oauthCompletion)
        
        return canHandleUrl
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

