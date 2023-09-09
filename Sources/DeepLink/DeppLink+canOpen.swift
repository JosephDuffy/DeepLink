#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension DeepLink {
    @available(iOSApplicationExtension, unavailable)
    @available(macOSApplicationExtension, unavailable)
    public static var canOpen: Bool {
        let schemeURL = URL(string: "\(scheme)://")!
        #if os(iOS)
        return UIApplication.shared.canOpenURL(schemeURL)
        #elseif os(macOS)
        return NSWorkspace.shared.urlForApplication(toOpen: schemeURL) != nil
        #endif
    }
}
