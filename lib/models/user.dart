import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'id')
  final String? id;
  
  @JsonKey(name: 'username')
  final String username;
  
  @JsonKey(name: 'email')
  final String email;
  
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  
  @JsonKey(name: 'bio')
  final String? bio;
  
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  @JsonKey(name: 'last_seen')
  final DateTime? lastSeen;
  
  String get profileImageUrl => profilePicture ?? 'default_profile_image_url';
  
  User({
    this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.bio,
    this.createdAt,
    this.lastSeen,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
