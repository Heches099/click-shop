/// One entry from the admin audit log (`/admin/audit-log`).
class AuditEntry {
  final String id;
  final String adminEmail;
  final String action;
  final String targetType;
  final String? targetId;
  final Map<String, dynamic> detail;
  final DateTime? createdAt;

  const AuditEntry({
    required this.id,
    this.adminEmail = '',
    required this.action,
    this.targetType = '',
    this.targetId,
    this.detail = const {},
    this.createdAt,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] as String?;
    return AuditEntry(
      id: json['id'] as String? ?? '',
      adminEmail: json['adminEmail'] as String? ?? '',
      action: json['action'] as String? ?? '',
      targetType: json['targetType'] as String? ?? '',
      targetId: json['targetId'] as String?,
      detail: (json['detail'] is Map)
          ? (json['detail'] as Map).cast<String, dynamic>()
          : const {},
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }
}