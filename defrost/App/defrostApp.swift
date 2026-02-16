
import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

// 1. Create the connector class
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    // Configure Firestore settings (updated for modern API)
    let db = Firestore.firestore()
    let settings = FirestoreSettings()
    settings.cacheSettings = MemoryCacheSettings() // Use memory-only cache (no persistence)
    db.settings = settings
    
    print("🔥 Firebase initialized successfully")
    return true
  }
}

@main
struct DefrostApp: App {
    // 2. Inject the connector into your app
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // 3. Create shared ViewModel
    @StateObject private var reportViewModel = ReportViewModel()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(reportViewModel)
        }
    }
}
