# Nextcloud iOS - Project Guide

## Overview

This is a white-label fork of the Nextcloud iOS app - a cloud storage client that syncs with Nextcloud/ownCloud servers. The app is GPLv3 licensed with Apple App Store exception.

**Current State:** Branch `avuz-customization-v7.2.2` - customization work in progress.

## Build Requirements

- **Xcode:** 26.0.1+ (macOS 15)
- **iOS Deployment Target:** 12.3+
- **Swift:** 5+
- **Firebase Config:** Required - place `GoogleService-Info.plist` at project root
  - For development: use [mock config](https://github.com/firebase/quickstart-ios/blob/master/mock-GoogleService-Info.plist)

### Build Steps

```bash
# 1. Clone and open project
open Nextcloud.xcodeproj

# 2. Add GoogleService-Info.plist to project root

# 3. Select target and build
# Xcode -> Product -> Build (Cmd+B)
```

## Project Structure

```
/Brand/                     # Branding assets and configuration (MAIN CUSTOMIZATION AREA)
  NCBrand.swift             # Brand options, colors, URLs
  Custom.xcassets/          # App icons, intro images, logo
  iOSClient.plist           # Main app Info.plist
  iOSClient.entitlements    # App capabilities & groups
  LaunchScreen.storyboard   # Launch screen
  Intro/                    # Onboarding screens

/iOSClient/                 # Main app source code
  AppDelegate.swift         # App entry point
  SceneDelegate.swift       # Scene management
  /Data/                    # Database models (Realm)
  /Networking/              # API calls
  /Files/                   # File browser
  /Media/                   # Media player
  ...                       # 40+ feature modules

/Share/                     # Share extension
/Widget/                    # Home screen widgets
/File Provider Extension/   # Files app integration
/Notification Service Extension/  # Push notifications
/Tests/                     # Unit, integration, UI tests
```

## Branding Customization

### 1. NCBrand.swift (`Brand/NCBrand.swift`)

Primary configuration file. Modify these values:

```swift
// App identity
var brand: String = "YourBrand"
var brandUserAgent: String = "YourBrand"
var textCopyrightNextcloudiOS: String = "YourBrand for iOS %@ © 2025"

// Server configuration
var loginBaseUrl: String = "https://your-cloud.com"
var pushNotificationServerProxy: String = "https://your-push-server.com"

// Links
var linkLoginHost: String = "https://your-site.com/install"
var linkloginPreferredProviders: String = "https://your-site.com/signup"
var privacy: String = "https://your-site.com/privacy"
var sourceCode: String = "https://github.com/your-org/your-app"
var appStoreUrl: String = "https://apps.apple.com/app/your-app/id123456789"

// URL scheme (must be unique)
var webLoginAutenticationProtocol: String = "yourbrand://"

// App Groups (change for your team)
var capabilitiesGroup: String = "group.com.yourbrand.app"
var capabilitiesGroupApps: String = "group.com.yourbrand.apps"

// Feature toggles
var disable_intro: Bool = false
var disable_multiaccount: Bool = false
var disable_crash_service: Bool = false
```

### 2. App Colors (`Brand/NCBrand.swift`)

```swift
// In NCBrandColor class
let customer: UIColor = UIColor(red: R/255.0, green: G/255.0, blue: B/255.0, alpha: 1.0)
var customerText: UIColor = .white
```

### 3. App Icons (`Brand/Custom.xcassets/AppIcon.appiconset/`)

Replace all PNG files with your branded icons. Required sizes:
- 1024x1024 (App Store)
- 180x180 (iPhone @3x)
- 120x120 (iPhone @2x)
- 167x167 (iPad Pro @2x)
- 152x152 (iPad @2x)
- 87x87, 80x80, 76x76, 72x72, 60x60, 58x58, 57x57, 50x50, 40x40, 29x29, 20x20

### 4. Logo (`Brand/Custom.xcassets/logo.imageset/`)

Replace `logo.svg` with your brand logo.

### 5. Intro Screens (`Brand/Custom.xcassets/`)

Replace `intro1.svg`, `intro2.png`, `intro3.png`, `intro4.png` with your onboarding images.

### 6. Launch Screen (`Brand/LaunchScreen.storyboard`)

Customize the launch screen appearance.

### 7. Info.plist Changes (`Brand/iOSClient.plist`)

```xml
<!-- Display name -->
<key>CFBundleDisplayName</key>
<string>YourBrand</string>

<!-- URL Scheme -->
<key>CFBundleURLSchemes</key>
<array>
    <string>yourbrand</string>
</array>

<!-- Background task identifiers -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.yourbrand.refreshTask</string>
    <string>com.yourbrand.processingTask</string>
</array>
```

### 8. Entitlements (All .entitlements files in Brand/)

Update App Groups in all entitlement files:
- `iOSClient.entitlements`
- `Share.entitlements`
- `Widget.entitlements`
- `File_Provider_Extension.entitlements`
- `File_Provider_Extension_UI.entitlements`
- `Notification_Service_Extension.entitlements`
- `WidgetDashboardIntentHandler.entitlements`

```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.yourbrand.apps</string>
    <string>group.com.yourbrand.app</string>
</array>
```

## App Store Distribution Checklist

### Apple Developer Account Setup

1. Create App ID with bundle identifier: `com.yourbrand.app`
2. Create App IDs for extensions:
   - `com.yourbrand.app.Share`
   - `com.yourbrand.app.Widget`
   - `com.yourbrand.app.File-Provider-Extension`
   - `com.yourbrand.app.File-Provider-Extension-UI`
   - `com.yourbrand.app.Notification-Service-Extension`
   - `com.yourbrand.app.WidgetDashboardIntentHandler`
3. Create App Groups:
   - `group.com.yourbrand.app`
   - `group.com.yourbrand.apps`
4. Enable capabilities: Push Notifications, App Groups, iCloud (if needed)
5. Create provisioning profiles for all targets

### Xcode Project Settings

1. Update PRODUCT_BUNDLE_IDENTIFIER in Build Settings for all targets
2. Update Development Team to your team ID
3. Configure signing for all targets

### Firebase Setup (Optional but recommended)

1. Create Firebase project
2. Add iOS app with your bundle identifier
3. Download `GoogleService-Info.plist`
4. Place at project root

### App Store Connect

1. Create new app
2. Fill in metadata, screenshots, description
3. Configure App Privacy
4. Submit for review

## Key Files Reference

| Purpose | File |
|---------|------|
| Brand configuration | `Brand/NCBrand.swift` |
| App icons | `Brand/Custom.xcassets/AppIcon.appiconset/` |
| Logo | `Brand/Custom.xcassets/logo.imageset/` |
| Main plist | `Brand/iOSClient.plist` |
| Entitlements | `Brand/iOSClient.entitlements` |
| Launch screen | `Brand/LaunchScreen.storyboard` |
| Onboarding | `Brand/Intro/NCIntroViewController.swift` |
| Database | `Brand/Database.swift` |
| Global constants | `iOSClient/NCGlobal.swift` |

## Dependencies (SPM)

- **NextcloudKit** - Nextcloud API SDK
- **Realm** - Local database (v10.54.6+)
- **Firebase** - Analytics, crash reporting, push
- **SVGKit** - SVG rendering
- **SwiftEntryKit** - UI notifications
- **KeychainAccess** - Secure storage
- See `Package.swift` / Xcode for full list

## Testing

```bash
# Run unit tests
xcodebuild test -project Nextcloud.xcodeproj -scheme Nextcloud -destination 'platform=iOS Simulator,name=iPhone 16'

# Start local test server (Docker required)
./Tests/Server.sh
```

## License

GPLv3 with Apple App Store exception. See `LICENSE.txt` and `COPYING.iOS`.
