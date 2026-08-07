# Real Affiliate & Ads Integration Plan

Transform the current placeholder infrastructure into a functional, persistent, and "alive" affiliate and ads system.

## User Review Required

> [!IMPORTANT]
> This plan involves adding `google_mobile_ads` dependency. Please ensure you have your AdMob app ID ready for production, although I will use test IDs for now.

> [!IMPORTANT]
> I will implement the Affiliate backend using a persistent `Hive` store for a "real" local experience. If you require true multi-device sync, we should move this to Firebase Firestore in a future step.

## Proposed Changes

### 1. Infrastructure & Core
- **[MODIFY] [pubspec.yaml](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/pubspec.yaml)**: Add `google_mobile_ads`.
- **[MODIFY] [app_constants.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/core/constants/app_constants.dart)**: Define `affiliateCommissionRate` (e.g., 0.1) and `storeBaseUrl`.
- **[MODIFY] [service_locator.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/core/services/service_locator.dart)**: Register Affiliate data source, repository, and use cases.

### 2. Ads System
- **[MODIFY] [ad_config.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/core/services/ad_config.dart)**:
  - Enable Ads (`enabled = true`).
  - Add AdMob unit IDs for Android/iOS.
- **[MODIFY] [google_ad_banner.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/core/widgets/google_ad_banner.dart)**:
  - Update to support both Web (`HtmlElementView`) and Mobile (`AdWidget`).

### 3. Affiliate Backend
- **[NEW] [affiliate_datasource_impl.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/data/datasource/affiliate_datasource_impl.dart)**:
  - Implement persistent storage for affiliate accounts, clicks, and commissions using Hive.
- **[MODIFY] [affiliate_repository_impl.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/data/repositories/affiliate_repository_impl.dart)**:
  - Ensure it correctly delegates to the new data source.

### 4. Referral Tracking & Attribution
- **[MODIFY] [main_scaffold.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/presentation/core/screens/main_scaffold.dart)**:
  - Logic to detect `ref` parameter in URLs or deep links and save it locally.
- **[MODIFY] [checkout_screen.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/presentation/checkout/screens/checkout_screen.dart)**:
  - Retrieve the saved referral code during checkout.
  - Trigger `recordSale` on successful order placement to attribute commission.

### 5. Profile UI Enhancement
- **[MODIFY] [profile_screen.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/presentation/profile/screens/profile_screen.dart)**:
  - Add a futuristic "Earnings HUD" section that displays live clicks and earned commissions.

## Verification Plan

### Automated Tests
- Unit tests for `AffiliateUseCase` to verify commission calculation and attribution logic.

### Manual Verification
- **Ads**: Verify test ads appear on both Web and Mobile (emulator).
- **Affiliate**:
  1. Join the program in the Affiliate Portal.
  2. Copy the referral link.
  3. Simulate an incoming click (e.g., append `?ref=MYCODE` to URL).
  4. Complete a checkout and verify the commission appears in the history and Profile HUD.
