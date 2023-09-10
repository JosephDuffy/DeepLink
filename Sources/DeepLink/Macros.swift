@attached(member, names: named(url))
public macro StaticDeepLink(_ string: String) = #externalMacro(module: "DeepLinkPlugin", type: "StaticDeepLink")

/// Expands to provide a `url` property that's built using the properties of the
/// type this macro is attached to.
///
/// Decorate a property with ``Host()`` to use it as the host of the URL. This
/// will produce a URL such as `scheme://host/pathItem1/pathItem2`. Decorating
/// more than 1 property with ``Host()`` will produce an error.
///
/// Decorate 1 or more properties with ``PathItem()`` to build a path for the
/// URL. Each property will be joined with `/`.
///
/// - parameter trailingSlash: When `true` and at least 1 property is decorated
///   with ``PathItem()`` a trailing `/` will be added to the path.
@attached(member, names: named(url))
public macro DeepLink(trailingSlash: Bool = false) = #externalMacro(module: "DeepLinkPlugin", type: "DeepLink")

@attached(peer)
public macro Host() = #externalMacro(module: "DeepLinkPlugin", type: "Host")

@attached(peer)
public macro PathItem() = #externalMacro(module: "DeepLinkPlugin", type: "PathItem")

@attached(peer)
public macro QueryItem(includeWhenNil: Bool = false) = #externalMacro(module: "DeepLinkPlugin", type: "QueryItem")

@attached(peer)
public macro QueryItem(name: String, includeWhenNil: Bool = false) = #externalMacro(module: "DeepLinkPlugin", type: "QueryItem")
