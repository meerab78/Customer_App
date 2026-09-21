# Customer Restaurant App
A Flutter-based customer-facing restaurant ordering app supporting Takeaway and Delivery orders, with full menu browsing, cart management, address handling, promotions, and loyalty rewards.
## Features
### Authentication
- Sign up, sign in, OTP verification, resend OTP
- Forgot password & password reset
- Guest checkout (order without login)
- Profile management (name, date of birth, gender) & account deletion
### Menu & Customization
- Branch selection with dynamic menu loading
- Category browsing and infinite scrolling
- Simple item add-to-cart
- Variation and choice selection for customizable items
- Nested deal selectors (deals with multiple sub-items and variations)
### Cart & Local Storage
- SQLite-based local cart persistence
- Dynamic pricing based on order type (Delivery vs Takeaway)
- Cart auto-clears after successful checkout
### Address & Delivery
- View, add, edit, and delete saved addresses (Profile & Checkout)
- Auto-created default "Home" address for first-time users
- Google Maps integration for address selection
- Live delivery fee calculation based on selected address
### Promotions & Loyalty
- Promo code and coupon validation
- List of available coupons per user
- Loyalty points system with transaction history
- Point-to-wallet conversion via redemption packages
- Wallet balance toggle at checkout
### Order Management
- Order placement for both Takeaway and Delivery
- Complex payload construction (variations, choices, deals)
- Live order tracking with Google Maps (rider location when out for delivery)
- Order history
### Other
- Call button on home screen (opens dialer with branch number)
- Light/Dark theme support across the entire app
- Social media links on profile screen
## Tech Stack
- **Framework:** Flutter / Dart
- **State Management:** Provider (ChangeNotifier)
- **Local Storage:** SQLite (sqflite), Shared Preferences
- **API Communication:** REST APIs (GET/POST) with Bearer Token authentication
- **Maps:** Google Maps SDK
- **API Testing:** Postman
## Getting Started
### Prerequisites
- Flutter SDK installed
- Android Studio / Xcode (for platform-specific builds)
- API base URL and credentials configured
### Installation
```bash
git clone <repository-url>
cd <project-folder>
flutter pub get
```
### Running the App
```bash
flutter run
```
### Building a Release APK
```bash
flutter build apk --release
The generated APK will be available at:
`build/app/outputs/flutter-apk/app-release.apk`
