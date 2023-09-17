#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

extension DeepLink {
    @available(iOSApplicationExtension, unavailable)
    @available(macOSApplicationExtension, unavailable)
    @MainActor
    public static var canOpen: Bool {
        let schemeURL = URL(string: "\(scheme)://")!
        #if os(iOS) || os(tvOS)
        return UIApplication.shared.canOpenURL(schemeURL)
        #elseif os(macOS)
        return NSWorkspace.shared.urlForApplication(toOpen: schemeURL) != nil
        #elseif os(watchOS)
        return false
        #endif
    }
}
