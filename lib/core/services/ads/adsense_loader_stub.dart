/// Non-web fallback: AdSense is a web-only feature, so everything no-ops.
library;

import 'dart:async';

const bool adsenseAvailable = false;

String registerAdSlot() => '';

Future<void> loadAdSense() async {}

void renderAdSlot(String viewType, String slotId) {}
