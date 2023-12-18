import SwiftSyntax

struct Property {
    /// The variable declaration the macro is attached to. This may contain more
    /// than 1 property, e.g. `var token1, token2: Int`.
    let variable: VariableDeclSyntax

    /// The pattern binding that defines the type and initial value of the type,
    /// if provided.
    let binding: PatternBindingSyntax

    /// The identifier of the property, e.g. the name.
    let identifier: IdentifierPatternSyntax

    /// The explicit type annotation associated with the property.
    ///
    /// If `binding.typeAnnotation` is `nil` a sibling property's type
    /// annotation is used by scanning the variable's bindings backwards. For
    /// example a variable declared as:
    ///
    /// `var prop1: Int, prop2, prop3: String`
    ///
    /// In this `prop1` is an `Int` but `prop2` and `prop3` are `String`s.
    var explicitTypeAnnotation: TypeAnnotationSyntax? {
        if let typeAnnotation = binding.typeAnnotation {
            return typeAnnotation
        }

        var closestTypeAnnotation: TypeAnnotationSyntax?

        for binding in variable.bindings.reversed() {
            if binding == self.binding {
                return closestTypeAnnotation
            }

            if let typeAnnotation = binding.typeAnnotation {
                closestTypeAnnotation = typeAnnotation
            }
        }

        assertionFailure("Failed to find binding in variable")
        return nil
    }

    /// The implicit type of the property. There will be scenarios this does not
    /// cover.
    var implicitTypeAnnotation: TypeAnnotationSyntax? {
        guard let initializer = binding.initializer else { return nil }
        if initializer.value.is(IntegerLiteralExprSyntax.self) {
            return TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("Int")))
        } else if initializer.value.is(BooleanLiteralExprSyntax.self) {
            return TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("Bool")))
        } else if initializer.value.is(StringLiteralExprSyntax.self) {
            return TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: .identifier("String")))
        } else {
            // TODO: Should also check for functions with `initializer.value.as(FunctionCallExprSyntax.self)`
            return nil
        }
    }

    var typeAnnotation: TypeAnnotationSyntax? {
        explicitTypeAnnotation ?? implicitTypeAnnotation
    }

    var isOptional: Bool {
        guard let typeAnnotation = typeAnnotation else { return false }
        if typeAnnotation.type.is(OptionalTypeSyntax.self) {
            return true
        } else if let identifierType = typeAnnotation.type.as(IdentifierTypeSyntax.self) {
            return identifierType.name.trimmed.text == "Optional"
        }

        return false
    }

    var defaultValue: ExprSyntax? {
        if let initializer = binding.initializer {
            return initializer.value
        }

        return nil
    }

    /// When `true` the property requires a value to be set during the
    /// initialisation of the type containing the property.
    var mustBeInitialised: Bool {
        if variable.bindingSpecifier.tokenKind == .keyword(.let) {
            return binding.initializer == nil
        }

        if let accessorBlock = binding.accessorBlock {
            switch accessorBlock.accessors {
            case .accessors(let accessorList):
                for accessor in accessorList {
                    switch accessor.accessorSpecifier {
                    case .keyword(.get):
                        return false
                    default:
                        break
                    }
                }
            case .getter:
                return false
            }
        }

        return true
    }
}
