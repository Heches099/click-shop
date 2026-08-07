enum AffiliateStatus {
  pending,
  active,
  suspended,
}

enum CommissionStatus {
  pending,
  approved,
  paid,
}

class AffiliateAccount {
  final String id;
  final String name;
  final String email;
  final String promoCode;
  final String paymentEmail;
  final AffiliateStatus status;
  final DateTime createdAt;
  final int totalClicks;
  final int totalSales;
  final double totalCommission;
  final double pendingBalance;

  const AffiliateAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.promoCode,
    required this.paymentEmail,
    this.status = AffiliateStatus.active,
    required this.createdAt,
    this.totalClicks = 0,
    this.totalSales = 0,
    this.totalCommission = 0,
    this.pendingBalance = 0,
  });

  bool get isActive => status == AffiliateStatus.active;

  AffiliateAccount copyWith({
    int? totalClicks,
    int? totalSales,
    double? totalCommission,
    double? pendingBalance,
  }) {
    return AffiliateAccount(
      id: id,
      name: name,
      email: email,
      promoCode: promoCode,
      paymentEmail: paymentEmail,
      status: status,
      createdAt: createdAt,
      totalClicks: totalClicks ?? this.totalClicks,
      totalSales: totalSales ?? this.totalSales,
      totalCommission: totalCommission ?? this.totalCommission,
      pendingBalance: pendingBalance ?? this.pendingBalance,
    );
  }
}

class AffiliateCommission {
  final String id;
  final String affiliateCode;
  final String orderId;
  final double orderAmount;
  final double rate;
  final double amount;
  final CommissionStatus status;
  final DateTime createdAt;

  const AffiliateCommission({
    required this.id,
    required this.affiliateCode,
    required this.orderId,
    required this.orderAmount,
    required this.rate,
    required this.amount,
    this.status = CommissionStatus.pending,
    required this.createdAt,
  });
}

class AffiliateClick {
  final String id;
  final String affiliateCode;
  final String source;
  final DateTime createdAt;

  const AffiliateClick({
    required this.id,
    required this.affiliateCode,
    required this.source,
    required this.createdAt,
  });
}

class AffiliateStats {
  final int clicks;
  final int sales;
  final double commission;
  final double conversionRate;
  final int pendingCommissions;

  const AffiliateStats({
    required this.clicks,
    required this.sales,
    required this.commission,
    required this.conversionRate,
    required this.pendingCommissions,
  });
}
