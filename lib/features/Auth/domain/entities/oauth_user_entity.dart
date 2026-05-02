import 'package:equatable/equatable.dart';

class OAuthUserEntity extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  const OAuthUserEntity({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, email, name, photoUrl];
}