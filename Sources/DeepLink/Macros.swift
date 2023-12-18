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
@attached(member, names: named(url), named(init))
public macro DeepLink(
    generateInitWithURL: Bool = false,
    trailingSlash: Bool = false
) = #externalMacro(module: "DeepLinkPlugin", type: "DeepLink")

@attached(member, names: named(url), named(scheme), named(init))
public macro DeepLink(
    scheme: String,
    generateInitWithURL: Bool = false,
    trailingSlash: Bool = false
) = #externalMacro(module: "DeepLinkPlugin", type: "DeepLink")

@attached(peer)
public macro Host() = #externalMacro(module: "DeepLinkPlugin", type: "Host")

@attached(peer)
public macro Port() = #externalMacro(module: "DeepLinkPlugin", type: "Port")

@attached(peer)
public macro PathItem() = #externalMacro(module: "DeepLinkPlugin", type: "PathItem")

@attached(peer)
public macro QueryItem(includeWhenNil: Bool = false) = #externalMacro(module: "DeepLinkPlugin", type: "QueryItem")

@attached(peer)
public macro QueryItem(name: String, includeWhenNil: Bool = false) = #externalMacro(module: "DeepLinkPlugin", type: "QueryItem")

@attached(peer)
public macro QueryItems() = #externalMacro(module: "DeepLinkPlugin", type: "QueryItems")

@attached(peer)
public macro User() = #externalMacro(module: "DeepLinkPlugin", type: "User")

@attached(member, names: named(description), named(init))
@attached(extension, conformances: TypedStringURLComponent)
public macro TypedStringURLComponent() = #externalMacro(module: "DeepLinkPlugin", type: "TypedStringURLComponent")
