import 'dart:async';

import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'ad_config.dart';
import '../seo/seo_service.dart';

/// Web implementation of the AdSense loader.
///
/// Uses `package:web` (dart:js_interop) only — never `dart:html` — so it
/// compiles for both JavaScript and Wasm/Skwasm targets.
const bool adsenseAvailable = true;

bool _scriptLoaded = false;
int _slotCounter = 0;

/// Creates a DOM container, registers it as a Flutter platform view and
/// returns the view type the widget should render.
String registerAdSlot() {
  final viewType = 'ad_slot_${_slotCounter++}';
  final element = web.document.createElement('div') as web.HTMLDivElement;
  element.id = viewType;
  element.style.width = '100%';
  element.style.height = '100%';
  ui_web.platformViewRegistry
      .registerViewFactory(viewType, (int viewId) => element);
  return viewType;
}

/// Injects the AdSense bootstrap script once per session, but only AFTER the
/// app has painted its first frame (`flutter-first-frame`). This keeps ad
/// initialization off the critical rendering path (protects LCP/INP/CLS).
Future<void> loadAdSense() async {
  if (_scriptLoaded || !AdConfig.isConfigured) return;

  // Wait for the first visual frame before pulling any ad code.
  await SeoService.instance.firstFrame;

  if (_scriptLoaded) return;
  _scriptLoaded = true;

  final script = web.document.createElement('script') as web.HTMLScriptElement;
  script.src =
      'https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js'
      '?client=${AdConfig.publisherClientId}';
  script.async = true;
  script.crossOrigin = 'anonymous';
  web.document.head!.appendChild(script);
}

/// Renders an AdSense `<ins>` unit inside the DOM element whose id matches
/// [viewType], then triggers AdSense to fill it.
///
/// The unit is given a fixed, explicit size (CLS-safe) so AdSense can never
/// push the surrounding layout down and trigger layout-shift penalties.
void renderAdSlot(String viewType, String slotId) {
  if (!AdConfig.isConfigured) return;
  final container = web.document.getElementById(viewType);
  if (container == null) return;

  final ins = web.document.createElement('ins') as web.HTMLElement;
  ins.className = 'adsbygoogle';
  ins.style.display = 'block';
  ins.style.width = '100%';
  ins.setAttribute('data-ad-client', AdConfig.publisherClientId);
  ins.setAttribute('data-ad-slot', slotId);
  ins.setAttribute('data-ad-format', 'auto');
  ins.setAttribute('data-full-width-responsive', 'false');
  container.append(ins);

  // Standard AdSense trigger: `(adsbygoogle = window.adsbygoogle || []).push({})`
  // executed in the page. Using an inline script avoids JS-interop friction and
  // works whether or not the bootstrap script has finished loading.
  final trigger = web.document.createElement('script') as web.HTMLScriptElement;
  trigger.text = 'adsbygoogle = window.adsbygoogle || []; '
      'adsbygoogle.push({});';
  web.document.body!.appendChild(trigger);
}
