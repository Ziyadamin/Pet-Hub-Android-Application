import 'User.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'Comment.dart';

class Post {
  User user;
  String postText;
  DateTime postDate;
  List<Comment> comments;
  int likeCount;
  bool liked;

  static List<Post> allPosts = [];

  Post({
    required this.user,
    required this.postText,
    required this.postDate,
    required this.likeCount,
    required this.liked,
    required List<Comment> comments,
  }) : comments = comments;

  Post.defaultConstructor()
      : user = User.defaultConstructor(),
        postText = "",
        postDate = DateTime.now(),
        comments = [],
        likeCount = 0,
        liked = false;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      user: User.fromJson(json['user']),
      postText: json['postText'],
      postDate: DateTime.parse(json['postDate']),
      likeCount: json['likeCount'],
      liked: json['liked'],
      comments: (json['comments'] as List<dynamic>)
          .map((commentJson) => Comment.fromJson(commentJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'postText': postText,
      'postDate': postDate.toIso8601String(),
      'likeCount': likeCount,
      'liked': liked,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  void toggleLike() {
    if (liked) {
      liked = false;
      likeCount--;
    } else {
      liked = true;
      likeCount++;
    }
  }

  static Future<void> savePosts() async {
    try {
      String posts = allPosts
          .map((post) =>
      '${post.user.name},${post.postText},${post.postDate.toString()},${post.likeCount},${post.comments.map((comment) => comment.toJson()).join(';')}')
          .join('\n');

      final file = await _localFile;
      await file.writeAsString(posts);
      print("Posts saved successfully!");
      loadPosts();
    } catch (e) {
      print("Error saving posts: $e");
    }
  }

  static Future<List<Post>> loadPosts() async {
    try {
      final postsFile = await _localFile; // File for posts
      File commentsFile = File('${(await getApplicationDocumentsDirectory()).path}/comments.txt');

      if (!(await commentsFile.exists())) {
        print("Comments file does not exist. Creating empty file.");
        await commentsFile.create(); // Create the file if it doesn't exist
      }

      String postsContent = await postsFile.readAsString();
      String commentsContent = await commentsFile.readAsString();

      List<Post> loadedPosts = [];
      List<String> postsLines = postsContent.split('\n');
      List<String> commentsLines = commentsContent.split('\n');

      Map<int, List<Comment>> commentsMap = {};

      for (String line in commentsLines) {
        List<String> data = line.split(',');
        if (data.length >= 7) { // Check for the required comment data
          int postIndex = int.tryParse(data[0]) ?? -1;
          String commenterName = data[1];
          String commenterPhone = data[2];
          String neighborhood = data[3];
          String city = data[4];
          String bio = data[5];
          String commentText = data[6];
          String commentDate = data[7];

          if (postIndex != -1) {
            User tempCommenter = User(
              name: commenterName,
              phoneNumber: commenterPhone,
              neighborhood: neighborhood,
              city: city,
              bio: bio,
            );

            Comment newComment = Comment(
              commenter: tempCommenter,
              commentText: commentText,
              commentDate: commentDate,
              post: Post.defaultConstructor(),
            );

            commentsMap.putIfAbsent(postIndex, () => []);
            commentsMap[postIndex]!.add(newComment);
          }
        }
      }

      // Loading Posts
      for (int i = 0; i < postsLines.length; i++) {
        String postContent = postsLines[i];
        List<String> postInfo = postContent.split(',');
        if (postInfo.length >= 3) {
          String username = postInfo[0];
          String text = postInfo[1];
          DateTime date = DateTime.tryParse(postInfo[2]) ?? DateTime.now();
          List<Comment> postComments = commentsMap[i] ?? []; // Get comments for the current post index

          User postUser = User(name: username, phoneNumber: "", neighborhood: "", city: "", bio: "");
          Post post = Post(user: postUser, postText: text, postDate: date, likeCount: 0, liked: false, comments: postComments);
          loadedPosts.add(post);
        }
      }

      return loadedPosts;
    } catch (e) {
      print("Error loading posts: $e");
      return [];
    }
  }

  static Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/posts.txt');
  }

  void createPost(String text, DateTime date) {
    Post newPost = Post(user: user, postText: text, postDate: date, likeCount: 0, liked: false, comments: []);
    allPosts.add(newPost);
    savePosts();
  }
}
