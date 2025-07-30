# TemperAare

Live temperature tracking for the Aare River in Olten, Switzerland.

## Overview

TemperAare is a Flutter mobile application that displays live temperature data for the Aare River in Olten. The app fetches temperature readings from a custom IoT sensor station and displays both air and water temperatures in a visual interface with historical charts.

## Features

- **Real-time Temperature Data**: Live air and water temperature readings
- **Interactive Charts**: Historical temperature data with zoom and pan navigation
- **Progressive Data Loading**: Intelligent data fetching for smooth chart navigation
- **Multilingual Support**: Available in German, English, and French
- **Responsive Design**: Optimized for both portrait and landscape orientations

## Development

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode for platform-specific development
- Git

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd temperaare

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Testing

```bash
# Run all tests
flutter test

# Run static analysis
flutter analyze

# Format code
flutter format .
```

## App Store Release Instructions

### Google Play Store Release

#### Prerequisites
1. **Google Play Developer Account**: You need a Google Play Console developer account ($25 one-time fee)
2. **App Signing**: Enable Google Play App Signing for security

#### Build Process
```bash
# 1. Update version in pubspec.yaml
# version: 1.8.0+17 (increment build number)

# 2. Build release App Bundle (recommended)
flutter build appbundle

# Alternative: Build split APKs per architecture (smaller downloads)
flutter build apk --split-per-abi

# For additional security (optional)
flutter build appbundle --obfuscate --split-debug-info=<directory>
```

#### Release Steps
1. **Prepare Release Assets**:
   - App icon: 512x512 PNG (already configured in `pubspec.yaml`)
   - Screenshots: Various device sizes (phone, tablet)
   - Feature graphic: 1024x500 PNG
   - App description in multiple languages

2. **Google Play Console Setup**:
   - Create new app in Play Console
   - Configure app details (name, description, category)
   - Set up content rating questionnaire
   - Configure pricing and distribution

3. **Upload Build**:
   - Go to "Release" → "Production"
   - Upload the AAB file from `build/app/outputs/bundle/release/`
   - Fill in release notes
   - Submit for review

4. **Required Permissions** (automatically handled by Flutter):
   - Internet access for API calls
   - Network state for connectivity checks

#### Android App Signing Setup
1. **Create Upload Keystore**:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
        -keysize 2048 -validity 10000 -alias upload
```

2. **Create key.properties file** (in `android/` directory):
```
storePassword=<password-from-previous-step>
keyPassword=<password-from-previous-step>
keyAlias=upload
storeFile=<location-of-the-key-store-file>
```

3. **Configure build.gradle** (in `android/app/build.gradle.kts` or `.gradle`):
   - Load keystore properties
   - Configure signing in android block
   - **Important**: Keep `key.properties` private and out of version control

#### Key Files for Android Release
- `android/app/build.gradle` - Version codes and signing config
- `android/app/src/main/AndroidManifest.xml` - App permissions and metadata
- `android/key.properties` - Signing key configuration (create this file, don't commit)

### Apple App Store Release

#### Prerequisites
1. **Apple Developer Account**: Active Apple Developer Program membership ($99/year)
2. **Xcode**: Latest version installed on macOS
3. **Certificates and Provisioning Profiles**: Set up in Apple Developer portal

#### Build Process
```bash
# 1. Update version in pubspec.yaml
# version: 1.8.0+17

# 2. Build iOS App Archive (recommended method)
flutter build ipa

# For additional security (optional)
flutter build ipa --obfuscate --split-debug-info=<directory>

# Alternative: Traditional Xcode build
flutter build ios --release
open ios/Runner.xcworkspace
```

#### Release Steps
1. **Xcode Configuration**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select "Runner" project → "Signing & Capabilities"
   - Configure Team and Bundle Identifier
   - Ensure "Automatically manage signing" is enabled

2. **Upload to App Store Connect**:
   - **Method 1 (Recommended)**: `flutter build ipa` creates build at `build/ios/ipa/*.ipa`
   - **Method 2**: Use Xcode → Product → Archive → Organizer → "Distribute App"
   - **Method 3**: Use Apple Transporter app or command line `xcrun altool`

3. **App Store Connect Setup**:
   - Create new app in App Store Connect with unique Bundle ID
   - Configure app information, pricing, and availability
   - Add app screenshots (required sizes: iPhone, iPad if supported)
   - Write app description and keywords
   - Set age rating and content warnings
   - Ensure minimum iOS deployment target is iOS 12 or later

4. **TestFlight and Review**:
   - Optionally test with TestFlight for internal/external testing
   - Submit for App Store review (typically 1-7 days)
   - Must comply with Apple's App Review Guidelines

#### Key Files for iOS Release
- `ios/Runner/Info.plist` - App configuration and permissions
- `ios/Runner.xcodeproj/project.pbxproj` - Project settings
- `ios/Runner/Assets.xcassets/` - App icons and launch images

### Version Management

Update version numbers in these files before each release:
- `pubspec.yaml`: `version: X.Y.Z+BUILD_NUMBER`
- Android: `android/app/build.gradle` (versionCode, versionName)
- iOS: Xcode project settings (automatically synced from pubspec.yaml)

### Release Checklist

#### Pre-Release
- [ ] Update version numbers
- [ ] Run full test suite: `flutter test`
- [ ] Verify analytics and crash reporting
- [ ] Test on multiple devices/simulators
- [ ] Update app store descriptions and screenshots
- [ ] Verify deep links and URL handling work correctly

#### Android Release
- [ ] Set up app signing keystore and key.properties
- [ ] Build signed AAB: `flutter build appbundle`
- [ ] Test release build on device
- [ ] Upload to Play Console internal testing
- [ ] Promote to production after testing
- [ ] Monitor Play Console for crashes

#### iOS Release  
- [ ] Configure Bundle ID and signing in Xcode
- [ ] Build IPA: `flutter build ipa`
- [ ] Upload to App Store Connect via Transporter/Xcode
- [ ] Test with TestFlight (optional)
- [ ] Submit for App Store review
- [ ] Monitor App Store Connect for issues

### App Store Optimization (ASO)

#### Keywords and Description
- **Primary Keywords**: temperature, Aare, river, Olten, Switzerland, water temperature
- **App Title**: "TemperAare - Aare Temperature"
- **Subtitle**: "Live river temperature in Olten"

#### Screenshots
- Show main temperature display
- Display historical charts
- Highlight multilingual support
- Include both portrait and landscape views

### Localization

The app supports multiple languages:
- **German** (de): Primary language
- **English** (en): International audience  
- **French** (fr): Swiss French speakers

Update localization files in `lib/l10n/` before release.

### Testing Release Builds

#### Android Testing
```bash
# Test app bundle offline using bundletool
java -jar bundletool.jar build-apks --bundle=build/app/outputs/bundle/release/app.aab --output=my_app.apks
java -jar bundletool.jar install-apks --apks=my_app.apks
```

#### iOS Testing
```bash
# Test the built IPA file
# Upload to App Store Connect and use TestFlight for testing
```

### Troubleshooting

#### Common Build Issues
- **Android**: Ensure `android/key.properties` is configured for signing
- **iOS**: Check certificates and provisioning profiles in Xcode
- **Dependencies**: Run `flutter pub get` and `flutter clean` if needed
- **Build failures**: Try `flutter clean` then rebuild
- **Signing issues**: Verify keystore passwords and file paths

#### Store Rejection Issues
- **Permissions**: Ensure only necessary permissions are requested
- **Content**: App must comply with store content policies
- **Functionality**: App must work as described in store listing

### Support and Maintenance

- Monitor app store reviews and ratings
- Update temperature data API endpoints if needed
- Regular dependency updates: `flutter pub upgrade`
- Test app functionality after iOS/Android system updates
