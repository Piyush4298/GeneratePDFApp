//
//  SceneDelegate.swift
//  GeneratePDFApp
//
//  Created by Piyush Pandey on 23/08/25.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        let container = NSPersistentContainer(name: "GeneratePDFApp")
        
        print("Core Data Model Entities: \(container.managedObjectModel.entities.map { $0.name ?? "unnamed" })")
        print("Core Data Model Version: \(container.managedObjectModel.versionIdentifiers)")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Core Data failed: \(error), \(error.userInfo)")
                // Fallback: show error UI, or use an in-memory store
                let description = NSPersistentStoreDescription()
                description.type = NSInMemoryStoreType
                container.persistentStoreDescriptions = [description]
                do {
                    try container.persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                                                                configurationName: nil,
                                                                                at: nil,
                                                                                options: nil)
                    print("Using in-memory Core Data store")
                } catch {
                    fatalError("Even in-memory store failed: \(error)")
                }
            } else {
                print("Core Data stores loaded successfully")
                print("Available entities: \(container.managedObjectModel.entities.map { $0.name ?? "unnamed" })")
            }
        })
        let coreDataService = CoreDataService(persistentContainer: container)
        let viewModel = TransactionViewModel(coreDataService: coreDataService)
        window?.rootViewController = UINavigationController(rootViewController: ViewController(viewModel: viewModel))
        window?.makeKeyAndVisible()
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

        // Save changes in the application's managed object context when the application transitions to the background.
    }


}

