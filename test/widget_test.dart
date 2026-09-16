import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:click_shop/main.dart';

void main() {
  setUpAll(() async {
    // Hive is initialised in production by `initServiceLocator()`; tests that
    // pump the full app must set it up too so the locale store can open.
    final dir = await Directory.systemTemp.createTemp('click_shop_test');
    Hive.init(dir.path);
  });

  testWidgets('app boots and renders the router', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}