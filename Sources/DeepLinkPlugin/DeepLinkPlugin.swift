import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct DeepLinkPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StaticDeepLink.self,
        DeepLink.self,
        Host.self,
        PathItem.self,
        QueryItem.self,
        QueryItems.self,
    ]
}
