class ContactModel {
  final String id;
  final String name;
  final String phone;

  ContactModel({required this.id, required this.name, required this.phone});

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone};
}
