import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../domain/usecases/discovery_usecase.dart';
import '../service_locator.dart';

/// Thin wrapper over the backend funnel sink (`POST /analytics/events`).
///
/// - Anonymous user/session id is generated once and persisted locally — no
///   personal data ever leaves the device for analytics.
/// - All calls are fire-and-forget and best-effort; analytics must never
///   interrupt shopping.
class EventTracker {
  DiscoveryUseCase? _useCase;
  String? _clientId;

  static const String _key = 'client_id';

  Future<String> _id() async {
    final cached = _clientId;
    if (cached != null) return cached;
    final box = await Hive.openBox<String>('analytics_box');
    var stored = box.get(_key);
    if (stored == null || stored.length < 8) {
      stored = 'cs-${DateTime.now().millisecondsSinceEpoch}-'
          '${Random().nextInt(999999).toString().padLeft(6, '0')}';
      await box.put(_key, stored);
    }
    _clientId = stored;
    return stored;
  }

  DiscoveryUseCase? get _discovery {
    if (_useCase != null) return _useCase;
    try {
      _useCase = sl<DiscoveryUseCase>();
    } catch (_) {
      return null;
    }
    return _useCase;
  }

  /// Fires an event if possible; silently no-ops otherwise (never throws).
  Future<void> track(
    String eventType, {
    String? productId,
    Map<String, dynamic> payload = const {},
  }) async {
    final useCase = _discovery;
    if (useCase == null) return;
    final clientId = await _id();
    try {
      await useCase.trackEvent(
        eventType: eventType,
        productId: productId,
        clientId: clientId,
        payload: payload,
      );
    } catch (_) {
      // non-fatal
    }
  }
}