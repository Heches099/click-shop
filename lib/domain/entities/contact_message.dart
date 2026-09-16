/// A support message submitted through the contact form.
class ContactMessageEntity {
  final String id;
  final String name;
  final String email;
  final String? subject;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const ContactMessageEntity({
    required this.id,
    required this.name,
    required this.email,
    this.subject,
    required this.message,
    this.isRead = false,
    this.createdAt,
  });

  factory ContactMessageEntity.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] as String?;
    return ContactMessageEntity(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      subject: json['subject'] as String?,
      message: json['message'] as String? ?? '',
      isRead: json['isRead'] == true,
      createdAt: created != null ? DateTime.tryParse(created) : null,
    );
  }
}