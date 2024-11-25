import 'dart:convert';

import 'package:Shepower/Dashboard/widgets/videocontroller.dart';
import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class User {
  final String firstname;
  final String profileImage;
  final String profileID;

  User({
    required this.firstname,
    required this.profileImage,
    required this.profileID,
  });
}

class Post {
  User user;
  String postImage;
  String postDescription;
  String createdAt;
  int totalLikes;
  int totalComments;
  String id;
  bool isLikedByCurrentUser;
  List<Comment> comments;

  Post({
    required this.user,
    required this.postImage,
    required this.postDescription,
    required this.createdAt,
    required this.totalLikes,
    required this.totalComments,
    required this.id,
    this.isLikedByCurrentUser = false,
    required this.comments,
    required List<User> likedPeople,
  });
}

class Comment {
  final String profileImage;
  final String firstName;
  final String commenterId;
  final String commentText;
  bool isLiked;
  final String commentId;
  List<Comment> replyComments;

  Comment({
    required this.profileImage,
    required this.firstName,
    required this.commenterId,
    required this.commentText,
    this.isLiked = false,
    required this.commentId,
    required this.replyComments,
  });
}

class DisplayPosts extends StatefulWidget {
  final String postId;

  DisplayPosts({
    Key? key,
    required this.postId,
  }) : super(key: key);

  State<DisplayPosts> createState() => _DisplayPostsState();
}

class _DisplayPostsState extends State<DisplayPosts> {
  List<Post> posts = [];
  String? userId;
  bool isGlobalCommenting = false;
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  Future<void> getPosts() async {
    final storage = FlutterSecureStorage();
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getAllPostsofMe'));
    request.body = json.encode({"user_id": widget.postId});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseBody);

      if (parsedResponse['Status'] == true) {
        final usersWithPosts = parsedResponse['results'];
        final List<Post> parsedPosts = [];

        for (var userPosts in usersWithPosts) {
          final user = User(
            firstname: userPosts['firstname'] ?? '',
            profileImage: userPosts['profile_img'] ?? '',
            profileID: userPosts['profileID'] ?? '',
          );

          final feed = userPosts['posts'];
          for (var post in feed) {
            // Convert totalLikes and totalComments to integers
            int likes = post['totallikesofpost'] != null
                ? int.tryParse(post['totallikesofpost'].toString()) ?? 0
                : 0;
            int comments = post['totalcomments'] != null
                ? int.tryParse(post['totalcomments'].toString()) ?? 0
                : 0;

            final isLikedByCurrentUser =
                (post['likedpeopledata'] as List).isNotEmpty &&
                    (post['likedpeopledata'] as List).any((likedPerson) =>
                        likedPerson is Map<String, dynamic> &&
                        likedPerson.containsKey('_id'));

            final List<User> likedPeople = (post['likedpeopledata'] as List)
                .where((likedPerson) =>
                    likedPerson is Map<String, dynamic> &&
                    likedPerson.containsKey('_id') &&
                    likedPerson['_id'] != null &&
                    likedPerson['_id'].isNotEmpty)
                .map<User>((likedPerson) => User(
                      firstname: likedPerson['firstname'] ?? '',
                      profileImage: likedPerson['profile_img'] ?? '',
                      profileID: likedPerson['profileID'] ?? '',
                    ))
                .toList();

            final postObj = Post(
              id: post['_id'] ?? '',
              user: user,
              postImage: post['Post'] ?? '',
              createdAt: post['createdAt'] ?? '',
              postDescription: post['Post_discription'] ?? '',
              likedPeople: likedPeople,
              totalLikes: likes,
              totalComments: comments,
              isLikedByCurrentUser: isLikedByCurrentUser,
              comments: [],
            );

            parsedPosts.add(postObj);
          }
        }

        setState(() {
          posts = parsedPosts;
        });
      } else {
        print("API returned an error message: ${parsedResponse['message']}");
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  Future<void> likePost(String postId, int indexOf) async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}likePost'));
    request.body = json.encode({"post_id": postId, "liker_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseBody);

      if (parsedResponse['Status'] == true) {
        int newLikeCount = posts[indexOf].totalLikes;
        if (posts[indexOf].isLikedByCurrentUser) {
          newLikeCount--;
        } else {
          newLikeCount++;
        }

        setState(() {
          posts[indexOf].isLikedByCurrentUser =
              !posts[indexOf].isLikedByCurrentUser;
          posts[indexOf].totalLikes = newLikeCount;
        });

        print(await response.stream.bytesToString());
      } else {
        print("API returned an error message: ${parsedResponse['message']}");
      }
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color.fromRGBO(216, 6, 163, 1),
                  Color.fromRGBO(99, 7, 114, 1),
                ],
              ).createShader(bounds);
            },
            child: Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1.5.w,
                  color: const Color.fromRGBO(99, 1, 114, 0.8),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(
                Icons.navigate_before,
                color: Colors.black,
              ),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title:  Text(
          'Posts'.tr(),
          style:const TextStyle(
              color: Color.fromRGBO(25, 41, 92, 1),
              fontFamily: 'Montserrat',
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostWidget(post: posts[index]);
        },
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        '${imagespath.baseUrl}${post.user.profileImage}'),
                  ),
                  const SizedBox(width: 16),
                  Text(post.user.firstname),
                ],
              ),
              // PopupMenuButton(
              //   itemBuilder: (BuildContext context) {
              //     return [
              //       const PopupMenuItem(
              //         value: "delete",
              //         child: Text("Delete"),
              //       ),
              //       const PopupMenuItem(
              //         value: "block",
              //         child: Text("Block"),
              //       ),
              //     ];
              //   },
              //   onSelected: (String value) {
              //     if (value == "delete") {
              //     } else if (value == "block") {}
              //   },
              // ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(217, 217, 217, 1),
              width: 0.5,
            ),
            color: const Color.fromARGB(255, 222, 235, 242),
          ),
          child: Center(
            child: post.postImage.endsWith('.mp4')
                ? VideoPlayerWidgetscreen(
                    videoUrl: '${imagespath.baseUrl}${post.postImage}')
                : Image.network(
                    '${imagespath.baseUrl}${post.postImage}',
                    fit: BoxFit.fill,
                  ),
          ),
        ),
        Text(
          post.postDescription,
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}






  // Likes, Comments, and Shares
        // Padding(
        //   padding: const EdgeInsets.all(
        //       8.0), // Add padding around the likes, comments, and shares section
        //   child: Row(
        //     children: [
        //       IconButton(
        //         icon: Icon(post.isLikedByCurrentUser
        //             ? Icons.favorite
        //             : Icons.favorite_border),
        //         onPressed: () {
        //           getalllikes(postId: post.id);
        //         },
        //       ),
        //       Text('${post.totalLikes} Likes'),
        //       IconButton(
        //         icon: Icon(Icons.comment),
        //         onPressed: () {
        //           // Open the comment section for this post
        //           // You can use showModalBottomSheet or a different UI for comments
        //         },
        //       ),
        //       Text('${post.totalComments} Comments'),
        //       IconButton(
        //         icon: Icon(Icons.share),
        //         onPressed: () {
        //           // Share functionality
        //         },
        //       ),
        //     ],
        //   ),
        // ),