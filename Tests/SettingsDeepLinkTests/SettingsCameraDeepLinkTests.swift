import DeepLinkTestSupport
import SettingsDeepLink
import XCTest

final class SettingsCameraDeepLinkTests: XCTestCase {
    func testWithoutPath() {
        let link = SettingsCameraDeepLink()
        AssertEqual(
            link.url,
            "prefs:CAMERA"
        )
    }

    func testRecordVideoPath() {
        let link = SettingsCameraDeepLink(path: .recordVideo)
        AssertEqual(
            link.url,
            "prefs:CAMERA?path=Record%20Video"
        )
    }

    func testRecordSloMoPath() {
        let link = SettingsCameraDeepLink(path: .recordSloMo)
        AssertEqual(
            link.url,
            "prefs:CAMERA?path=Record%20Slo-mo"
        )
    }
}
