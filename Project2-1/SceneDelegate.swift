//
//  SceneDelegate.swift
//  DrobboxTest
//
//  Created by 황동혁 on 9/5/25.
//

import UIKit
import SwiftyDropbox

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
            guard let windowScene = (scene as? UIWindowScene) else { return }

             window = UIWindow(windowScene: windowScene)
             let mainViewController = ViewController()
             let navigationController = UINavigationController(rootViewController: mainViewController)

             window?.rootViewController = navigationController
             window?.makeKeyAndVisible()
        }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
          for context in URLContexts {
              let oauthCompletion: DropboxOAuthCompletion = { authResult in
                  if let authResult = authResult {
                      switch authResult {
                      case .success:
                          print("드롭박스 인증 성공!")
                          // 메인 뷰컨트롤러에 인증 완료 알림
                          NotificationCenter.default.post(name: NSNotification.Name("DropboxAuthSuccess"), object: nil)
                      case .cancel:
                          print("드롭박스 인증 취소")
                      case .error(_, let description):
                          print("드롭박스 인증 오류: \(description ?? "")")
                      }
                  }
              }
              
              DropboxClientsManager.handleRedirectURL(context.url, includeBackgroundClient: false, completion: oauthCompletion)
          }
      }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


