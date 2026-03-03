import 'package:viora_app/core/connections/api/end_points.dart';
import 'package:viora_app/features/user/data/models/sub_model/company_model.dart';
import 'package:viora_app/features/user/domain/entities/user_entity.dart';
import 'package:viora_app/features/user/domain/entities/sub_entities/address_entity.dart';

class UserModel extends UserEntity {
  int id;
  final String username;
  final CompanyModel company;
  UserModel({
    required this.id,
    required this.username,
    required this.company,

    required super.name,
    required super.email,
    required super.phone,
    required super.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[ApiKey.id],
      name: json[ApiKey.name],
      username: json[ApiKey.username],
      email: json[ApiKey.email],
      phone: json[ApiKey.phone],
      address: AddressEntity(
        street: json[ApiKey.address][ApiKey.street],
        city: json[ApiKey.address][ApiKey.city],
        state: json[ApiKey.address][ApiKey.state],
      ),
      company: CompanyModel.fromJson(json[ApiKey.company]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ApiKey.id: id,
      ApiKey.name: name,
      ApiKey.username: username,
      ApiKey.email: email,
      ApiKey.phone: phone,
      ApiKey.address: {
        ApiKey.street: address.street,
        ApiKey.city: address.city,
        ApiKey.state: address.state,
      },
      ApiKey.company: company.toJson(),
    };
  }
}
