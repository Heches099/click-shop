# 1000/10 Premium Onboarding with Background Assets

Upgrade the onboarding experience to use high-quality local assets from `assets/images` as full-screen backgrounds, mimicking the provided minimalist high-fashion template.

## Goal Description
Transform the current onboarding into a visually immersive "lookbook" style experience. Instead of solid color gradients, each page will feature a full-bleed model image from the local assets, with minimalist glassmorphic UI overlays for navigation and storytelling.

## User Review Required

> [!IMPORTANT]
> I will be using the following local assets as backgrounds:
> 1. `assets/images/Ganor - Zip Neck Tracksuit Set Modern Fit.jpg`
> 2. `assets/images/Luxury Corporate Boss Lady, Navy Blue Blazer & White Trouser Office outfits_.jpg`
> 3. `assets/images/Timeless Old Money Style for Men.jpg`
>
> Please ensure these filenames are exact in your project.

## Proposed Changes

### [Presentation Layer - Onboarding]

#### [MODIFY] [onboarding_screen.dart](file:///C:/Users/HECHES/Desktop/E-com1/click_shop/lib/presentation/onboarding/screens/onboarding_screen.dart)
- Update `_slides` to use the selected local background images.
- Redesign the slide layout to be "full-bleed" (image covers the entire background).
- Add a dark/light gradient overlay to the bottom of images to ensure text legibility.
- Implement floating "Collection" or "Product" preview chips to match the template's look.
- Refine the "Skip" and "Next" buttons to use a more minimalist, high-end design (borders, blur).

## Verification Plan

### Automated Tests
- Run `flutter analyze` to ensure no issues with asset paths or imports.

### Manual Verification
- **Visual Audit**: Verify images are centered and cover the screen properly (`BoxFit.cover`).
- **Typography Check**: Ensure text is sharp and readable against both light and dark model images.
- **Animation Check**: Ensure the parallax or fade transitions between high-res images are performant.
