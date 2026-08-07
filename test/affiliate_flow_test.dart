import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:click_shop/data/datasource/local_affiliate_datasource.dart';
import 'package:click_shop/domain/entities/affiliate.dart';

void main() {
  late Directory tempDir;
  late HiveAffiliateDataSource dataSource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('affiliate_test');
    Hive.init(tempDir.path);
    dataSource = HiveAffiliateDataSource();
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('affiliate signup -> referral link -> sale attribution', () async {
    // No affiliate yet.
    expect(await dataSource.getAccount(), isNull);

    // Affiliate signs up and gets a promo code.
    final account = await dataSource.createAccount(
      name: 'Test Affiliate',
      email: 'affiliate@example.com',
      paymentEmail: 'payout@example.com',
    );
    expect(account.promoCode, startsWith('CS-'));
    expect(account.promoCode, isNotEmpty);

    // Sales before any referral is attributed should be ignored.
    expect(await dataSource.recordSale(orderId: 'ORD-0', orderAmount: 100),
        isNull);

    // A visitor opens the affiliate's link: the click is counted and the
    // code is stored for the session.
    await dataSource.recordClick(code: account.promoCode, source: 'test');
    await dataSource.setRefCode(account.promoCode);

    // That visitor completes a $100 order -> 10% commission.
    final commission =
        await dataSource.recordSale(orderId: 'ORD-1', orderAmount: 100);
    expect(commission, isNotNull);
    expect(commission!.affiliateCode, account.promoCode);
    expect(commission.amount, closeTo(10.0, 0.001));

    // Dashboard stats reflect the referral.
    final stats = await dataSource.getStats();
    expect(stats.clicks, 1);
    expect(stats.sales, 1);
    expect(stats.commission, closeTo(10.0, 0.001));

    // A bogus / unknown code must not produce a commission.
    await dataSource.setRefCode('CS-NOPE99');
    expect(await dataSource.recordSale(orderId: 'ORD-2', orderAmount: 50),
        isNull);
  });

  test('commission history and payout', () async {
    final account = await dataSource.createAccount(
      name: 'Second Affiliate',
      email: 'second@example.com',
      paymentEmail: '',
    );
    await dataSource.setRefCode(account.promoCode);

    await dataSource.recordSale(orderId: 'ORD-A', orderAmount: 300);

    final commissions = await dataSource.getCommissions();
    expect(commissions, hasLength(1));
    expect(commissions.first.amount, closeTo(30.0, 0.001));
    expect(commissions.first.status, CommissionStatus.pending);

    await dataSource.requestPayout();

    final after = await dataSource.getCommissions();
    expect(after.first.status, CommissionStatus.paid);
    final stats = await dataSource.getStats();
    expect(stats.commission, closeTo(0.0, 0.001));
  });
}
