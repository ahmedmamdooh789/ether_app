import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  @JsonKey(name: 'id')
  final String id;
  
  @JsonKey(name: 'user')
  final User user;
  
  @JsonKey(name: 'content')
  final String content;
  
  @JsonKey(name: 'media')
  final List<String>? mediaUrls;
  
  @JsonKey(name: 'likes_count')
  final int likesCount;
  
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  @JsonKey(name: 'is_saved')
  late final bool isSaved;
  
  @JsonKey(includeFromJson: false, includeToJson: false)
  late final bool isLiked;
  
  String get userImage => user.profileImageUrl;
  
  String get postImage => mediaUrls?.isNotEmpty == true ? mediaUrls![0] : '';
  
  String get text => content;
  
  int get comments => commentsCount;
  
  int get likes => likesCount;
  
  Post({
    required this.id,
    required this.user,
    required this.content,
    this.mediaUrls,
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    this.isSaved = false,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  String? get username => null;

  String? get userHandle => null;
  
  Map<String, dynamic> toJson() => _$PostToJson(this);
  
  // Manual copyWith implementation
  Post copyWith({
    String? id,
    User? user,
    String? content,
    List<String>? mediaUrls,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }
  
  // Helper method to toggle like status
  Post toggleLike() {
    return copyWith(
      isLiked: !isLiked,
      likesCount: isLiked ? likesCount - 1 : likesCount + 1,
    );
  }
  
  // Helper method to increment comment count
  Post incrementCommentCount() {
    return copyWith(commentsCount: commentsCount + 1);
  }
  
  // Helper method to decrement comment count
  Post decrementCommentCount() {
    return commentsCount > 0 
        ? copyWith(commentsCount: commentsCount - 1)
        : this;
  }
}
