# UIViewRepresentableWithModifier

## Introduction
In a SwiftUI project, sometimes we need to use certain UIKit widgets when they are not available in SwiftUI. Cases are `UIActivityIndicatorView`, `WKWebView`, `UIImagePickerController`, etc. We wrap these UIKit widgets to be conformed to `UIViewRepresentable` or `UIViewControllerRepresentable` so that they will just be like a `View` in SwiftUI View hierachy. One thing we lack in the wrapped widgets is that all native SwiftUI Views also provide bountiful modifiers like `.frame()`, `.onAppear()`, etc. which are really convinient. In this example we are constructing a SwiftUI-y `SearchBar` from `UISearchBar` with a couple of custom modifiers.

## Key Tricks
### Modifiers
The SearchBar we are constructing is named `SearchBarUIViewRepresentable`. Since there have been tons of tutorials/examples on how to wrap a UIKit widget with `UIViewRepresentable` or `UIViewControllerRepresentable`, we don't repeat it here. We just focus on how to add modifiers to `SearchBarUIViewRepresentable`. Since a modifier is always called after the instantiation of `SearchBarUIViewRepresentable`, which is a struct, meaning that the members (properties) are immutable, we add a container named `MutatingWrapper`, which is of `class` type, to hold all the modifiers to be added later on.
```
struct SearchBarUIViewRepresentable: UIViewRepresentable {
    ...
    private var mutatingWrapper = MutatingWrapper()
    
    class MutatingWrapper {
        ...
        var placeholder: String? = nil
        var keyboardType: UIKeyboardType = .default
        ...
    }
    
    ...
    
    func placeholder(_ placeholder: String) -> Self {
        mutatingWrapper.placeholder = placeholder
        return self
    }
    
    func keyboardType(_ keyboardType: UIKeyboardType) -> Self {
        mutatingWrapper.keyboardType = keyboardType
        return self
    }
    ...
}
```
### Binding Variables
We also need to pass the `searchText` from `UISearchBar` to outside. We use a `Binding` variable to achieve this. Inside `SearchBarUIViewRepresentable` we have a `Coordinator` serving as `UISearchBarDelegate`, from which the `searchText` is updated. We can't pass the binding variable through into the `Coordinator` like this  

![](https://github.com/zjkuang/UIViewRepresentableWithModifier/blob/master/diagram01.png)
or define an optional binding variable in `Coordinator` for later population like this  

![](https://github.com/zjkuang/UIViewRepresentableWithModifier/blob/master/diagram02.png)
We deal with this matter with our `MutatingWrapper` this way
```
struct SearchBarUIViewRepresentable: UIViewRepresentable {
    @Binding var searchText: String
    private var mutatingWrapper = MutatingWrapper()
    
    class MutatingWrapper {
        ...
        var coordinator: Coordinator? = nil
        ...
    }
    
    init(binding searchText: Binding<String>) {
        _searchText = searchText
        makeCoordinator()
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var searchText: String
        ...
    }
    
    @discardableResult func makeCoordinator() -> SearchBarUIViewRepresentable.Coordinator {
        if mutatingWrapper.coordinator == nil {
            mutatingWrapper.coordinator = Coordinator(binding: $searchText)
        }
        return mutatingWrapper.coordinator!
    }
    ...
}
```
## How to Use

![](https://github.com/zjkuang/UIViewRepresentableWithModifier/blob/master/how-to-use.gif)
## Run

![](https://github.com/zjkuang/UIViewRepresentableWithModifier/blob/master/run.gif)
