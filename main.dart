import 'dart:io';
import 'package:flutter/material.dart';
import 'User.dart';
import 'Post.dart';
import 'Comment.dart';
import 'sign_up_page.dart'; // Make sure this is the correct path to your sign-up page file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  User newUser = User(
    name: "Mostafa",
    phoneNumber: "1234567890",
    neighborhood: "ABC",
    city: "XYZ",
    bio: "this is a test user",
  );

  List<Post> loadedPosts = await Post.loadPosts(); // Load saved posts
  Post.allPosts = loadedPosts;

  runApp(MyApp(myUser: newUser));
}

class MyApp extends StatelessWidget {
  final User myUser;

  MyApp({required this.myUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/loginOrSignUp',
      routes: {
        '/loginOrSignUp': (context) => LoginOrSignUpPage(),
        '/home': (context) => MyHomePage(user: myUser),
        '/createPost': (context) => CreatePostPage(user: myUser),
        '/userInfo': (context) => UserInfoPage(user: myUser),
      },
    );
  }
}

class LoginOrSignUpPage extends StatelessWidget {
  void _goToHomePage(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LoginPage(onLoginSuccess: () => _goToHomePage(context)),
                ));
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

// Assuming a basic structure for LoginPage
class LoginPage extends StatelessWidget {
  final Function onLoginSuccess;

  LoginPage({required this.onLoginSuccess});

  void _handleLogin() {
    // TODO: Implement your login logic here
    // On successful login
    onLoginSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleLogin,
          child: Text('Log In'),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final User user;

  MyHomePage({required this.user});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Post> posts = Post.allPosts; // Get all posts

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: PostsList(posts: posts, user: widget.user), // Display posts with user info
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User Info',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/createPost').then((_) {
              setState(() {
                posts = Post.allPosts; // Refresh the posts list after creating a new post
              });
            });
          } else if (index == 2) {
            Navigator.pushNamed(context, '/userInfo');
          }
        },
      ),
    );
  }
}

class PostsList extends StatefulWidget {
  final List<Post> posts;
  final User user;

  PostsList({required this.posts, required this.user});

  @override
  _PostsListState createState() => _PostsListState();
}

class _PostsListState extends State<PostsList> {
  List<bool> showComments = [];
  List<bool> likedPosts = []; // To track liked posts

  @override
  void initState() {
    super.initState();
    showComments = List.filled(widget.posts.length, false);
    likedPosts = List.filled(widget.posts.length, false); // Initialize likedPosts list
  }

  void _addCommentToPost(BuildContext context, Post post) async {
    TextEditingController commentController = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Enter your comment'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                String enteredComment = commentController.text;
                if (enteredComment.isNotEmpty) {
                  Comment newComment = Comment(
                    commentText: enteredComment,
                    commenter: widget.user, // Assuming the logged-in user adds the comment
                    commentDate: DateTime.now().toString(),
                    post: post,
                  );
                  setState(() {
                    post.comments.add(newComment);
                  });
                  _storeComment(post, newComment); // Saving comment to file
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _storeComment(Post post, Comment comment) {
    try {
      File file = File('comments.txt');
      IOSink sink = file.openWrite(mode: FileMode.append);
      sink.write('${widget.posts.indexOf(post)},'); // Store post index first
      sink.write('${comment.commenter.name},');
      sink.write('${comment.commenter.phoneNumber},');
      sink.write('${comment.commenter.neighborhood},');
      sink.write('${comment.commenter.city},');
      sink.write('${comment.commenter.bio},');
      sink.write('${comment.commentText},');
      sink.write('${comment.commentDate}\n'); // Store comment date
      sink.close();
    } catch (e) {
      print('Error storing comment: $e');
    }
  }


  void _toggleLike(int index) {
    setState(() {
      likedPosts[index] = !likedPosts[index]; // Toggle like for the given index
      if (likedPosts[index]) {
        widget.posts[index].likeCount++;
      } else {
        widget.posts[index].likeCount--;
      }
      widget.posts[index].liked = likedPosts[index];
      Post.savePosts(); // Save the updated post information
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        String formattedDate = "${widget.posts[index].postDate.day.toString().padLeft(2, '0')}-"
            "${widget.posts[index].postDate.month.toString().padLeft(2, '0')}-"
            "${widget.posts[index].postDate.year}";

        return Container(
          margin: EdgeInsets.all(8.0),
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.posts[index].user.name,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: Icon(
                        likedPosts[index] ? Icons.favorite : Icons.favorite_border,
                        color: likedPosts[index] ? Colors.red : null,
                      ),
                      onPressed: () {
                        _toggleLike(index); // Call the toggle like function
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(widget.posts[index].postText),
                subtitle: Text(formattedDate),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comments (${widget.posts[index].comments.length})',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (showComments[index])
                      Column(
                        children: [
                          for (var comment in widget.posts[index].comments)
                            Text('- ${comment.commentText}'),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showComments[index] = !showComments[index];
                            });
                          },
                          child: Text(showComments[index] ? 'Hide Comments' : 'Show Comments'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _addCommentToPost(context, widget.posts[index]);
                          },
                          child: Text('Add Comment'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CreatePostPage extends StatefulWidget {
  final User user;

  CreatePostPage({required this.user});

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Create Post'),
    ),
    body: Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    TextField(
    controller: textEditingController,
    decoration: InputDecoration(
    hintText: 'Enter your post text',
    ),
    ),
    SizedBox(height: 20),
    ElevatedButton(
    onPressed: () {
    String text = textEditingController.text;
    if (text.isNotEmpty) {
    setState(() {
    widget.user.createPost(text, DateTime.now());
    });
    Navigator.pop(context);
    }
    },
    child: Text('Create Post'),
    ),
    ],
    ),
    ),
    );
  }
}

class UserInfoPage extends StatelessWidget {
  final User user;

  UserInfoPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(user.neighborhood),
            Text(user.city),
            Text(user.bio),
          ],
        ),
      ),
    );
  }
}