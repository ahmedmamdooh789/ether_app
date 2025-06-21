import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'reply.g.dart';

@JsonSerializable()
class Reply {
  @JsonKey(name: 'id')
  final String id;
  
  @JsonKey(name: 'user')
  final User user;
  
  @JsonKey(name: 'content')
  final String content;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'replying_to')
  final String replyingTo;

  Reply({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.replyingTo,
  });

  factory Reply.fromJson(Map<String, dynamic> json) => _$ReplyFromJson(json);
  
  Map<String, dynamic> toJson() => _$ReplyToJson(this);
}
