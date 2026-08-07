import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'ad_config.dart';

/// Web implementation of the AdSense loader.
const bool adsenseAvailable = true;

bool _scriptLoaded = false;
int _slotCounter = 0;

/// Creates a DOM container, registers it as a Flutter platform view and
/// returns the view type the widget should render.
String registerAdSlot() {
  final viewType = 'ad_slot_${_slotCounter++}';
  final element = web.document.createElement('div');
  element.id = viewType;
  ui_web.platformViewRegistry
      .registerViewFactory(viewType, (int viewId) => element);
  return viewType;
}

/// Injects the AdSense bootstrap script once per session.
void loadAdSense() {
  if (_scriptLoaded || !AdConfig.isConfigured) return;
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
void renderAdSlot(String viewType, String slotId) {
  if (!AdConfig.isConfigured) return;
  final container = web.document.getElementById(viewType);
  if (container == null) return;

  final ins = web.document.createElement('ins') as web.HTMLElement;
  ins.className = 'adsbygoogle';
  ins.style.display = 'block';
  ins.setAttribute('data-ad-client', AdConfig.publisherClientId);
  ins.setAttribute('data-ad-slot', slotId);
  ins.setAttribute('data-ad-format', 'auto');
  ins.setAttribute('data-full-width-responsive', 'true');
  container.append(ins);

  // Standard AdSense trigger: `(adsbygoogle = window.adsbygoogle || []).push({})`
  // executed in the page. Using an inline script avoids JS-interop friction and
  // works whether or not the bootstrap script has finished loading.
  final trigger = web.document.createElement('script') as web.HTMLScriptElement;
  trigger.text = 'adsbygoogle = window.adsbygoogle || []; '
      'adsbygoogle.push({});';
  web.document.body!.appendChild(trigger);
}
