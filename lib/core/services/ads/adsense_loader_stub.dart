/// Non-web fallback: AdSense is a web-only feature, so everything no-ops.
const bool adsenseAvailable = false;

String registerAdSlot() => '';

void loadAdSense() {}

void renderAdSlot(String viewType, String slotId) {}
