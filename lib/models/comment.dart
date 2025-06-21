import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'reply.dart';

part 'comment.g.dart';

@JsonSerializable()
class Comment {
  @JsonKey(name: 'id')
  final String id;
  
  @JsonKey(name: 'user')
  final User user;
  
  @JsonKey(name: 'content')
  final String content;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'replies', defaultValue: [])
  final List<Reply> replies;

  Comment({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
