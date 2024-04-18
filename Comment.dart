import 'User.dart';
import 'Post.dart';

class Comment {
  User commenter;
  Post post;
  String commentDate;
  String commentText;

  Comment({
    required this.commenter,
    required this.post,
    required this.commentDate,
    required this.commentText,
  });

  Comment.defaultConstructor()
      : commenter = User.defaultConstructor(),
        post = Post.defaultConstructor(),
        commentDate = '',
        commentText = '';

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commenter: User.fromJson(json['commenter']),
      post: Post.fromJson(json['post']),
      commentDate: json['commentDate'],
      commentText: json['commentText'],
    );
  }

  factory Comment.fromRawString(String commentText) {
    return Comment(
      commenter: User.defaultConstructor(), // Adjust as necessary for commenter
      post: Post.defaultConstructor(), // Adjust as necessary for the post
      commentDate: '', // Set the comment date accordingly
      commentText: commentText, // Pass the provided comment text
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commenter': commenter.toJson(),
      'post': post.toJson(),
      'commentDate': commentDate,
      'commentText': commentText,
    };
  }
}
