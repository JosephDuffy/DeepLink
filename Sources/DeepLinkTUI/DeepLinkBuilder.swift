import CallsheetDeepLink
import DeepLink
import SwiftTUI

struct App: Identifiable {
    let name: String
    let deepLinks: [DeepLinkType]

    var id: String {
        name
    }
}

struct DeepLinkType: Identifiable {
    let type: any ParameterisedDeepLink.Type

    var id: String {
        "\(type)"
    }
}

extension App: CaseIterable {
    static let allCases: [App] = [
        .callsheet,
    ]
}

extension App {
    static var callsheet: App {
        App(
            name: "Callsheet",
            deepLinks: [
                DeepLinkType(type: MediaDetailsCallsheetDeepLink.self),
                DeepLinkType(type: SearchCallsheetDeepLink.self),
                DeepLinkType(type: TVEpisodeCallsheetDeepLink.self),
                DeepLinkType(type: TVSeasonCallsheetDeepLink.self),
            ]
        )
    }
}

struct DeepLinkBuilder: View {
    @State private var selectedApp: App?
    @State private var selectedDeepLinkType: DeepLinkType?
    @State private var createdDeepLink: Result<any DeepLink, Error>?

    var body: some View {
        VStack {
            HStack {
                AppPicker(selectedApp: $selectedApp)

                if let selectedApp {
                    DeepLinkPicker(selectedApp: selectedApp, selectedDeepLinkType: $selectedDeepLinkType)
                }

                if let selectedDeepLinkType {
                    DeepLinkParametersForm(deepLinkType: selectedDeepLinkType) { parameters in
                        do {
                            let deepLink = try selectedDeepLinkType.type.makeWithParameters(parameters)
                            createdDeepLink = .success(deepLink)
                        } catch {
                            createdDeepLink = .failure(error)
                        }
                    }
                }
            }

            if let createdDeepLink {
                switch createdDeepLink {
                case .success(let deepLink):
                    HStack {
                        Text("Created deep link:")
                        Text(deepLink.url.absoluteString)
                    }
                case .failure(let error as DeepLinkParameterError):
                    Text("Failed to create deep link: \(error.parameterName) is invalid: \(error.localizedDescription)")
                case .failure(let error):
                    Text("Failed to create deep link: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct DeepLinkParametersForm: View {
    @State var parameterValues: [Int: String] = [:]

    private let submitButtonHandler: (_ parameters: [String]) -> Void

    private let deepLinkType: DeepLinkType

    var body: some View {
        VStack {
            Text("\(deepLinkType.type.self)")
                .bold()

            let parameters = Array(
                zip(
                    deepLinkType.type.deepLinkParameters.indices,
                    deepLinkType.type.deepLinkParameters
                )
            )

            ForEach(parameters, id: \.0) { tuple in
                let parameter = tuple.1
                HStack {
                    Text(parameter.name + ":")
                    TextField { newValue in
                        parameterValues[tuple.0] = newValue
                    }
                }
            }

            Button("Build") {
                submitButtonHandler(parameterValues.lazy.sorted(by: { $0.key < $1.key }).map(\.value))
            }
        }
        .border()
    }

    init(deepLinkType: DeepLinkType, submitButtonHandler: @escaping (_ parameters: [String]) -> Void) {
        self.deepLinkType = deepLinkType
        self.submitButtonHandler = submitButtonHandler
    }
}

struct AppPicker: View {
    @Binding private var selectedApp: App?

    var body: some View {
        VStack {
            Text("App")
                .bold()

            ForEach(App.allCases) { app in
                Button(app.name) {
                    selectedApp = app
                }
            }

        }
        .border()
    }

    internal init(selectedApp: Binding<App?>) {
        _selectedApp = selectedApp
    }
}

struct DeepLinkPicker: View {
    private let selectedApp: App

    @Binding private var selectedDeepLinkType: DeepLinkType?

    var body: some View {
        VStack {
            Text(selectedApp.name)
                .bold()

            ForEach(selectedApp.deepLinks) { deepLink in
                Button("\(deepLink.type)") {
                    selectedDeepLinkType = deepLink
                }
            }
        }
        .border()
    }

    internal init(selectedApp: App, selectedDeepLinkType: Binding<DeepLinkType?>) {
        self.selectedApp = selectedApp
        _selectedDeepLinkType = selectedDeepLinkType
    }
}
