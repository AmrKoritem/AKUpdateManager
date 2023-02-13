[![Swift](https://img.shields.io/badge/Swift-5.0+-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.0+-Orange?style=flat-square)
[![iOS](https://img.shields.io/badge/iOS-Platform-blue?style=flat-square)](https://img.shields.io/badge/iOS-Platform-Blue?style=flat-square)
[![tvOS](https://img.shields.io/badge/tvOS-Platform-blue?style=flat-square)](https://img.shields.io/badge/tvOS-Platform-Blue?style=flat-square)
[![CocoaPods](https://img.shields.io/badge/CocoaPods-Support-yellow?style=flat-square)](https://img.shields.io/badge/CocoaPods-Support-Yellow?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-Support-yellow?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-Support-Yellow?style=flat-square)

# AKUpdateManager

AKUpdateManager manages your app updates.<br>

## Installation

AKUpdateManager can be installed using [CocoaPods](https://cocoapods.org). Add the following lines to your Podfile:
```ruby
pod 'AKUpdateManager'
```

You can also install it using [swift package manager](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) as well.
```swift
dependencies: [
    .package(url: "https://github.com/AmrKoritem/AKUpdateManager.git", .upToNextMajor(from: "1.0.1"))
]
```

## Usage

In the `AppDelegate.application(_:didFinishLaunchingWithOptions:)` method, add the following line:
```swift
    AKUpdateManager.shared.checkForUpdates()
```

AKUpdateManager will show the user an alert telling him to update his app if there was any. The alert will be blocking if the needed update is major. However, you can override AKUpdateManager response by providing your own implementation as follows:
```swift
    AKUpdateManager.shared.checkForUpdates { updateInfo in
        // Add your own implementation here.
     }
```

## Examples

You can check the example project here to see AKUpdateManager in action 🥳.<br>
You can check a full set of examples [here](https://github.com/AmrKoritem/AKLibrariesExamples) as well.

## Contribution 🎉

All contributions are welcome. Feel free to check the [Known issues](https://github.com/AmrKoritem/AKUpdateManager#known-issues) and [Future plans](https://github.com/AmrKoritem/AKUpdateManager#future-plans) sections if you don't know where to start. And of course feel free to raise your own issues and create PRs for them 💪

## Known issues 🫣

Thankfully, there are no known issues at the moment.

## Future plans 🧐

1 - Override the default alert strings and actions. [#1](https://github.com/AmrKoritem/AKUpdateManager/issues/2)<br>
2 - Add a method to show a custom view/viewController instead of the alert. [#2](https://github.com/AmrKoritem/AKUpdateManager/issues/3)<br>

## Find me 🥰

[LinkedIn](https://www.linkedin.com/in/amr-koritem-976bb0125/)

## License

Please check the license file.
