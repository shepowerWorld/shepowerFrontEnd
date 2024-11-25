import 'dart:convert';

import 'package:Shepower/Createpost.dart';
import 'package:Shepower/Dashboard/widgets/videocontroller.dart';
import 'package:Shepower/GetAlllikes.dart';
import 'package:Shepower/Myprofile/myprofile.dart';
import 'package:Shepower/Otherprofile/OtherProfile.dart';
import 'package:Shepower/common/api.service.dart';
import 'package:Shepower/common/cache.service.dart';
import 'package:Shepower/screens/post/models/commentReply.model.dart';
import 'package:Shepower/service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/addreplyservice.dart';

class User {
  final String id;
  final String firstname;
  final String profileImage;
  final String profileID;

  User({
    required this.id,
    required this.firstname,
    required this.profileImage,
    required this.profileID,
  });
}

class Post {
  final User user;
  final String postImage;
  final String postDescription;
  final String createdAt;
  final List<User> likedPeople;
  int totalLikes;
  int totalComments;
  final String id;
  bool isLikedByCurrentUser;
  bool isCommentSectionExpanded = false;
  List<Comment> comments;
  bool isCommentSectionOpen = false;

  Post({
    required this.user,
    required this.postImage,
    required this.postDescription,
    required this.createdAt,
    required this.likedPeople,
    required this.totalLikes,
    required this.totalComments,
    required this.id,
    this.isLikedByCurrentUser = false,
    required this.comments,
  });
}

class Comment {
  final String profileImage;
  final String firstName;
  final String commenterId;
  final String commentText;
  bool isLiked;
  int likedCount; //likes count
  final String commentId;
  int commentCount; // Add a comment count field
  int replyCommentCount; // Add this property
  final String replyCommentId; // Add a replyCommentId property
  bool hasReplies; // Add this property
  bool isReplySectionOpen = false;
  bool showReplies; // Add this property
  bool isReply;
  final bool isPostComment; // Add this property
  List<dynamic> subcomment;
  List<dynamic> replyComments;

  Comment({
    required this.profileImage,
    required this.firstName,
    required this.commenterId,
    required this.commentText,
    this.likedCount = 0,
    this.isLiked = false, // Initialize it to false by default
    required this.commentId,
    this.commentCount = 0, // Initialize the count to 0
    this.replyCommentCount = 0, // Initialize with 0
    this.replyCommentId = '',
    this.replyComments = const [],
    this.hasReplies = false, // Initialize it to false by default
    this.showReplies = false,
    this.isReply = false, // Initialize it to false by default
    required this.isPostComment,
    this.subcomment = const [],
  });
}

class Explorescreen extends StatefulWidget {
  final Comment? comment;
  const Explorescreen({Key? key, this.comment}) : super(key: key);

  @override
  State<Explorescreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<Explorescreen> {
  var storage = const FlutterSecureStorage();
  bool isExpanded = false;
  List<Post> posts = [];
  String? likerId;
  bool isGlobalCommenting = false;
  List<Comment> comments = [];
  String postId = '';
  String id = '';
  String firstname = '';
  String myCommenterName = "";
  List<Post> postsList = [];
  bool showReplies = false;
  String reason = '';
  bool isLoading = false;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();

    storage.write(key: "istrue", value: "false");
    setState(() {
      _loadProfileID();
      init();
    });
    Future.microtask(() {
      init();
    });

    storage.read(key: '_id').then((value) {
      if (value != null) {
        setState(() {
          id = value;
        });
      }
    });
    fetchCommenterName('yourDynamicKey').then((commenterName) {
      setState(() {
        myCommenterName = commenterName;
      });
    });
  }

  init() async {
    try {
      await getallPost();
      await getComment('');
      await getStoredParameters();
    } catch (e) {
    } finally {}
  }

  Future<void> _loadProfileID() async {
    final profileData = await getProfile();
    setState(() {
      firstname = profileData['firstname'];
    });
  }

  Future<Map<String, dynamic>> getProfile() async {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getMyprofile/$id'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      Map<String, dynamic> data = json.decode(responseBody);
      print('responseBody data: $data');

      String firstname = data['result']['firstname'];

      return {
        'firstname': firstname,
      };
    } else {
      throw Exception(response.reasonPhrase);
    }
  }

  Future<String> fetchCommenterName(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final storedCommenterName = prefs.getString(key); // Use the provided key
    print('Fetched Commenter Name: $storedCommenterName');
    return storedCommenterName ?? '';
  }

  Future<Map<String, String?>> getStoredParameters() async {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    print('Explore$id');

    return {
      'id': id,
    };
  }

  Future<void> shareImageLink(String text) async {
    try {
      await launch('whatsapp://send?text=$text');
    } catch (e) {
      print('Error: $e');
    }
  }

  void toggleCommentSection(Post post) {
    setState(() {
      post.isCommentSectionOpen = !post.isCommentSectionOpen;

      if (!post.isCommentSectionOpen) {
        post.comments.clear();
      }
    });
  }

  void postCommentCallbackWrapper(String postId, String text) {
    final postIndex = posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      setState(() {
        posts[postIndex].totalComments++;
      });
    }
    postComment(postId, text);
  }

  Future<void> getallPost() async {
    const storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');

    String? accessToken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request =
        http.Request('POST', Uri.parse('${ApiConfig.baseUrl}getPostsOfAll'));
    request.body = json.encode({"user_id": id});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseBody);

      _refreshController.refreshCompleted();
      if (parsedResponse['Status'] == true) {
        final usersWithPosts = parsedResponse['UsersWithPosts'];
        print('usersWithPosts$usersWithPosts');
        List<Post> parsedPosts = [];

        for (var userPosts in usersWithPosts) {
          final user = User(
            id: userPosts['_id'],
            firstname: userPosts['firstname'] ?? '',
            profileImage: userPosts['profile_img'] ?? '',
            profileID: userPosts['profileID'] ?? '',
          );

          final feed = userPosts['feed'];
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
                        likedPerson.containsKey('_id') &&
                        likedPerson['_id'] == id);

            final List<User> likedPeople = (post['likedpeopledata'] as List)
                .where((likedPerson) =>
                    likedPerson is Map<String, dynamic> &&
                    likedPerson.containsKey('_id') &&
                    likedPerson['_id'] != null &&
                    likedPerson['_id'].isNotEmpty)
                .map<User>((likedPerson) => User(
                      id: likedPerson['_id'],
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

        parsedPosts = parsedPosts.reversed.toList();
        getComment('');
        setState(() {
          posts = parsedPosts;
        });
      } else {
        print("API returned an error message: ${parsedResponse['message']}");
      }
    } else {
      _refreshController.refreshCompleted();
      print(response.reasonPhrase);
    }
  }

  Future<void> deletePost(String postId, String ownerId) async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    if (id == ownerId) {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };

      var request =
          http.Request('DELETE', Uri.parse('${ApiConfig.baseUrl}deletePost'));
      request.body = json.encode({
        "_id": postId,
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print("Post deleted successfully.");
        var responseBody = await response.stream.bytesToString();
        print(" Response body: $responseBody");

        // Update the UI: Remove the deleted post from the list
        setState(() {
          posts.removeWhere((post) => post.id == postId);
        });

        // Show the "Post deleted successfully" alert
        customAlertDialog(context);
      } else {
        print("Failed to delete post. Status code: ${response.statusCode}");
      }
    } else {
      print("You are not authorized to delete this post.");
    }
  }

  void customAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(150),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD80683),
                        Color(0xFF630772),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in_sharp,
                        size: 48.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                const Center(
                  child: Text(
                    "Post deleted successfully",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFD80683),
                          Color(0xFF630772),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ok',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> likePost(String postId, int indexOf) async {
    final storage = const FlutterSecureStorage();
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
      print('responseBody$responseBody');
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

  Future<void> postComment(String postId, String text) async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');

    String? accesstoken = await storage.read(key: 'accessToken');

    final Uri uri = Uri.parse('${ApiConfig.baseUrl}addComment');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    final Map<String, dynamic> jsonData = {
      'post_id': postId,
      'commenter_id': id,
      'text': text,
    };
    final String requestBody = json.encode(jsonData);

    try {
      final http.Response response = await http.post(
        uri,
        headers: headers,
        body: requestBody,
      );
      if (response.statusCode == 200) {
        print('Comment posted successfully.');
        print('Response Body: ${response.body}');
      } else {
        print('HTTP Error: ${response.statusCode}, ${response.reasonPhrase}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      print('Network Error: $error');
    }
  }

  Future<void> getComment(String postId) async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');

    String? accesstoken = await storage.read(key: 'accessToken');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request = http.Request(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}getComment'),
    );

    request.body = json.encode({
      "post_id": postId,
    });

    request.headers.addAll(headers);

    try {
      http.Response response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}getComment'),
        headers: headers,
        body: json.encode({
          "post_id": postId,
        }),
      );
      if (response.statusCode == 200) {
        final parsedResponse = json.decode(response.body);
        final commentsData = parsedResponse['response'] as List<dynamic>;

        if (commentsData.isNotEmpty) {
          // Find the post with the matching postId
          final postIndex = posts.indexWhere((post) => post.id == postId);

          if (postIndex != -1) {
            // Clear existing comments
            posts[postIndex].comments.clear();

            // Loop through the comments data and add them to the post
            for (var commentData in commentsData) {
              final profileImage =
                  commentData['commentdetails']['profile_img'] ?? '';
              final firstName =
                  commentData['commentdetails']['firstname'] ?? '';
              final commentText = commentData['text'] ?? '';
              final Commentid = commentData['_id'] ?? '';
              final Commentid1 = commentData['_id'] ?? '';
              final replyComments = commentData['replies'] ?? '';
              int likesCount = commentData['totallikesofcomments'] ?? 0;
              final comment = Comment(
                likedCount: likesCount,
                profileImage: profileImage,
                firstName: firstName,
                commentText: commentText,
                commenterId: Commentid,
                commentId:
                    Commentid1, // Use 'id' if it's not null, otherwise use an empty string
                isPostComment: true,
                replyComments: [],
              );
              final subcommentData = commentData['replies'] as List<dynamic>;
              if (subcommentData.isNotEmpty) {
                for (var subcommentItem in subcommentData) {
                  final subProfileImage =
                      subcommentItem['commentdetails']['profile_img'] ?? '';
                  final subFirstName =
                      subcommentItem['commentdetails']['firstname'] ?? '';
                  final subCommentText = subcommentItem['text'] ?? '';
                  final subCommentId = subcommentItem['_id'] ?? '';
                  int likesCount = subcommentItem['totallikesofcomments'] ?? 0;
                  bool isLiked = subcommentItem['commentlikerDetails']
                      .any((likerDetails) => likerDetails['_id'] == id);

                  print('Is Liked....reply: $isLiked');

                  final subcomment = Comment(
                      likedCount: likesCount,
                      profileImage: '${imagespath.baseUrl}$subProfileImage',
                      firstName: subFirstName,
                      commentText: subCommentText,
                      commenterId: subCommentId,
                      commentId: subCommentId,
                      isLiked: isLiked,
                      isPostComment: false);

                  print('subcomment$subcomment');

                  comment.replyComments.add(subcomment);
                }
              }
              print('subcomment$replyComments');
              print('subcommentsubcomment$replyComments');
              posts[postIndex].comments.add(comment);
            }

            // Toggle the comment section to open
            toggleCommentSection(posts[postIndex]);
            print(
                "Comments for post ${posts[postIndex].id} retrieved successfully.");
          }
        } else {
          print("No comments for this post.");
        }
      } else {
        print("HTTP Error: ${response.statusCode}, ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Error: $error");
    } finally {
      // Set isLoading to false when the operation is completed
      isLoading = false;
    }
  }

  Widget _buildRatings(double user) {
    double rating = user;

    int filledStars = rating.floor();
    double fractionalPart = rating - filledStars;

    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Filled stars
          for (int i = 0; i < filledStars; i++)
            Icon(
              Icons.star,
              color: Colors.orange,
              size: 20,
            ),
          // Partially filled or empty star
          if (fractionalPart > 0)
            Icon(
              Icons.star_half,
              color: Colors.orange,
              size: 20,
            ),
          // Empty stars
          for (int i = 0; i < 5 - rating.ceil(); i++)
            Icon(
              Icons.star_border,
              color: Colors.orange,
              size: 20,
            ),
        ],
      ),
    );
  }

  void _openCommentBottomSheet(
      BuildContext context, Post post, List<Post> posts) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return CommentBottomSheet(
          post: post,
          postCommentCallback: this.postCommentCallbackWrapper,
          toggleCommentSection: () {
            setState(() {
              post.isCommentSectionExpanded = !post.isCommentSectionExpanded;
            });
          },
          posts: posts,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.025;
    Localizations.localeOf(context);

    return Scaffold(
      body: SmartRefresher(
        onRefresh: () => getallPost(),
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              children: [
              
                const SizedBox(
                  height: 20,
                ),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(217, 217, 217, 1)
                            .withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                        color: const Color.fromRGBO(217, 217, 217, 1),
                        width: 1),
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.circular(22.11.r),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 20, 15),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                              "share_thought".tr(),
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromRGBO(0, 0, 0, 1),
                              )),
                        ),
                        SizedBox(
                          height: 6.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) {
                                    return CreatePostScreen(postData: true);
                                  },
                                ));
                              },
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color.fromRGBO(
                                          241, 244, 245, 1),
                                      width: 1),
                                  color: const Color(0xFFF1F4F5),
                                  borderRadius: BorderRadius.circular(9.21.r),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(left: 2.0),
                                        child: Icon(
                                          Icons.photo_camera,
                                          color: Colors.pink,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text("Photo_video".tr(),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.06.sp,
                                              color: const Color.fromRGBO(
                                                  83, 87, 103, 1))),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                for (var post in posts)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: EdgeInsets.only(bottom: 10.h),
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(217, 217, 217, 1)
                                .withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                            color: const Color.fromRGBO(217, 217, 217, 1),
                            width: 1),
                        color: const Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      if (id == post.user.id) {
                                        return MyProfile(myId: post.user.id);
                                      } else {
                                        return Otherprofile(
                                            userId: post.user.id, myId: id);
                                      }
                                    },
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      '${imagespath.baseUrl}${post.user.profileImage}',
                                    ),
                                    radius: 25.r,
                                  ),
                                  SizedBox(width: 5.w),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(post.user.firstname,
                                          style: GoogleFonts.roboto(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: post.user.profileID
                                                    .startsWith('citizen')
                                                ? Colors.black
                                                : const Color.fromRGBO(
                                                    216, 6, 131, 1),
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.timelapse,
                                              size: 12,
                                              color: Colors.grey[500],
                                            ),
                                            Text(
                                              formatNotificationTime(
                                                  post.createdAt),
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w500,
                                                fontSize: fontSize,
                                                height: 1.21875,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (BuildContext context) {
                                final isCurrentUserOwner = id == post.user.id;
                                return [
                                  if (!isCurrentUserOwner)
                                    PopupMenuItem(
                                      value: 'block',
                                      textStyle: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 16.sp,
                                          color: const Color.fromRGBO(
                                              24, 25, 31, 1)),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Block',
                                            style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16.sp,
                                                color: const Color.fromRGBO(
                                                    24, 25, 31, 1)),
                                          ),

                                          // Add more options or content if needed
                                        ],
                                      ),
                                    ),
                                  if (isCurrentUserOwner)
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Text('Delete'),
                                            // Add more options or content if needed
                                          ],
                                        ),
                                      ),
                                    ),
                                  // Add more options here if needed
                                ];
                              },
                              onSelected: (value) {
                                if (value == 'block') {
                                  final TextEditingController reason =
                                      TextEditingController();
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Confirm Deletion",
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20.sp,
                                            color: const Color.fromRGBO(
                                                24, 25, 31, 1),
                                          ),
                                        ),
                                        content: Form(
                                          child: TextFormField(
                                            controller: reason,
                                          ),
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              // Close the dialog
                                              Navigator.of(context)
                                                  .pop(); // Close the error dialog
                                            },
                                            child: Text("Cancel",
                                                style: GoogleFonts.montserrat(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 14.sp,
                                                    color: const Color.fromRGBO(
                                                        24, 25, 31, 1))),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              bool? result =
                                                  await CommentReplyService()
                                                      .blockUser(
                                                          post.id,
                                                          post.user.id,
                                                          reason.text);
                                              Navigator.of(context)
                                                  .pop(); // Close the Confirm Deletion dialog
                                              if (result == true) {
                                                print("Blocked Successfully");

                                                setState(() {
                                                  posts.removeWhere((item) =>
                                                      item.id == post.id);
                                                });

                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                          "Blocked Successfully"),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close the success dialog
                                                          },
                                                          child:
                                                              const Text("OK"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                print("Error");

                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text("Error"),
                                                      content: const Text(
                                                          "An error occurred. Please try again."),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Close the error dialog
                                                          },
                                                          child:
                                                              const Text("OK"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            child: const Text(
                                              "Block",
                                              style: TextStyle(
                                                color: Color(0xFF2C2C2C),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else if (value == 'delete') {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Confirm Deletion"),
                                        content: const Text(
                                            "Are you sure you want to delete this post?"),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              // Close the dialog
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style: TextStyle(
                                                color: Color(0xFF2C2C2C),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              deletePost(post.id, post.user.id);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Color(0xFF2C2C2C),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        Text(post.postDescription,
                            style: GoogleFonts.montserrat(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromRGBO(45, 63, 123, 1),
                            )),

                        // Post Image
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
                                    videoUrl:
                                        '${imagespath.baseUrl}${post.postImage}')
                                : Image.network(
                                    '${imagespath.baseUrl}${post.postImage}',
                                    // width: 323.w,
                                    // height: 400.h,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Row(
                              children: [
                                for (var likedPerson in post.likedPeople)
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return getalllikes(postId: post.id);
                                          },
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              '${imagespath.baseUrl}${likedPerson.profileImage}'),
                                          radius: 15,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await likePost(
                                        post.id,
                                        posts.indexOf(post),
                                      );
                                      setState(() {
                                        if (isPostLiked(post)) {
                                          post.totalLikes--;
                                        } else {
                                          post.totalLikes++;
                                        }
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          color: post.isLikedByCurrentUser
                                              ? const Color.fromARGB(
                                                  255, 231, 34, 3)
                                              : const Color.fromARGB(
                                                  255, 217, 180, 198),
                                          size: 23.0,
                                        ),
                                        SizedBox(width: 5.w),
                                        Text('${post.totalLikes}',
                                            style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15.sp,
                                                color: const Color.fromRGBO(
                                                    0, 0, 0, 1))),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _openCommentBottomSheet(
                                            context, post, posts);
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/explore/comment.png',
                                          width: 50.45.w,
                                          height: 30.01.h,
                                        ),
                                        Text('${post.totalComments}'),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      String imageUrl =
                                          "${imagespath.baseUrl}${post.postImage}";
                                      shareImageLink(imageUrl);
                                    },
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          'assets/explore/shar.png',
                                          width: 59.45.w,
                                          height: 30.01.h,
                                        ),
                                        const SizedBox(width: 4),
                                        //Text('${post.totalComments}'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (post.likedPeople.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                                'Liked by ${post.likedPeople[0].firstname} and ${post.likedPeople.length - 1} others',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11.48,
                                  fontWeight: FontWeight.w600,
                                  color: const Color.fromRGBO(0, 0, 0, 1),
                                )),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: GestureDetector(
                            onTap: () {
                              if (!post.isCommentSectionExpanded) {
                                getComment(
                                  post.id,
                                );
                              }
                            },
                            child: Text(
                                'View all ${post.totalComments} comments',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0,
                                  color: const Color.fromARGB(255, 12, 12, 12),
                                )),
                          ),
                        ),

                        if (post.isCommentSectionOpen)
                          CommentSection(
                            comments: post.comments,
                            postId: post.id,
                            postCommentCallback: postCommentCallbackWrapper,
                            commenterName: myCommenterName,
                            posts: postsList, // Pass your list of posts here
                          ),
                      ],
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isPostLiked(Post post) {
    return post.likedPeople.any((user) => user.id == likerId);
  }

  String formatNotificationTime(String createdAt) {
    try {
      final currentTime = DateTime.now();
      final notificationTime = DateTime.parse(createdAt);
      final timeDifference = currentTime.difference(notificationTime);

      if (timeDifference.inMinutes < 1) {
        return 'Just now';
      } else if (timeDifference.inHours < 1) {
        return '${timeDifference.inMinutes} minute${timeDifference.inMinutes > 1 ? 's' : ''} ago';
      } else if (timeDifference.inHours < 24) {
        return '${timeDifference.inHours} hour${timeDifference.inHours > 1 ? 's' : ''} ago';
      } else if (timeDifference.inDays < 7) {
        return '${timeDifference.inDays} day${timeDifference.inDays > 1 ? 's' : ''} ago';
      } else if (timeDifference.inDays < 30) {
        final weeks = (timeDifference.inDays / 7).floor();
        return '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else if (timeDifference.inDays < 365) {
        final months = (timeDifference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else {
        final years = (timeDifference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return 'Invalid Date Format';
    }
  }
}

class CommentSection extends StatefulWidget {
  final List<Comment> comments;
  final String postId;
  final Function(String, String) postCommentCallback;
  final String? commenterName;
  final List<Post> posts;
  bool showReplies = false;

  CommentSection({
    required this.comments,
    required this.postId,
    required this.postCommentCallback,
    this.commenterName,
    required this.posts,
  });

  @override
  _CommentSectionState createState() => _CommentSectionState(postsList: posts);
}

class _CommentSectionState extends State<CommentSection> {
  bool isReplying = false;
  Comment? selectedComment;
  bool isCurrentlyLiked = false;

  List<Post> postsList = [];

  List<Widget> commentWidgets = [];

  _CommentSectionState({required List<Post> postsList}) {
    this.postsList = postsList;
  }

  get posts => null;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  Future<void> getComment(String postId) async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accessToken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    var request = http.Request(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}getComment'),
    );

    request.body = json.encode({
      "post_id": postId,
    });

    request.headers.addAll(headers);

    try {
      http.Response response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}getComment'),
        headers: headers,
        body: json.encode({
          "post_id": postId,
        }),
      );
      if (response.statusCode == 200) {
        final parsedResponse = json.decode(response.body);
        print(parsedResponse);
      } else {
        print("HTTP Error: ${response.statusCode}, ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Error: $error");
    } finally {}
  }

  Future<void> _initPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    for (var comment in widget.comments) {
      final isLiked =
          prefs.getBool('comment_${comment.commentId}_isLiked') ?? false;
      setState(() {
        comment.isLiked = isLiked;
      });
    }
  }

  Future<bool> handleLike(Comment comment, String? replyCommentId) async {
    if (replyCommentId == null) {
      return _toggleLike(comment);
    } else {
      return replyCommentlike(widget.postId, comment.commentId, replyCommentId);
    }
  }

  Future<bool> _toggleLike(Comment comment) async {
    final isCurrentlyLiked = comment.isLiked;
    setState(() {
      comment.isLiked = !isCurrentlyLiked;
    });
    await saveLikeStatus(comment);
    final isSuccessful = await commentLike(widget.postId, comment.commentId);

    if (!isSuccessful) {
      setState(() {
        comment.isLiked = isCurrentlyLiked;
      });
    }

    return isSuccessful;
  }

  Future<void> saveLikeStatus(Comment comment) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'comment_${comment.commentId}_isLiked', comment.isLiked);
  }

  Future<bool> commentLike(String postId, String commentId) async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accessToken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}likeComment'),
        headers: headers,
        body: json.encode({
          "post_id": postId,
          "comment_id": commentId,
          "liker_id": id,
        }),
      );

      if (response.statusCode == 200) {
        print('Like successful');
        print(response.body);
        return true;
      } else {
        print('Like failed: ${response.statusCode} - ${response.reasonPhrase}');
        print(response.body);
        return false;
      }
    } catch (error) {
      print("Error: $error");
      return false;
    }
  }

  Future<Map<String, dynamic>> likeReplyComment(
      postId, commentId, replyCommentId) async {
    try {
      String? id = await CacheService.getUserId();
      if (id == null) return {};
      String url = '${ApiConfig.baseUrl}replyCommentlike';
      Map<String, dynamic> body = {
        "post_id": postId,
        "comment_id": commentId,
        "replycomment_id": replyCommentId,
        "liker_id": id,
      };
      Map<String, dynamic> response = await ApiService().post(url, body);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> replyCommentlike(
      String postId, String commentId, String replyCommentId) async {
    final storage = const FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accessToken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}replyCommentlike'),
        headers: headers,
        body: json.encode({
          "post_id": postId,
          "comment_id": commentId,
          "replycomment_id": replyCommentId,
          "liker_id": id,
        }),
      );
      if (response.statusCode == 200) {
        print('Reply Like successful n');
        print(response.body);
        return true; // Like operation was successful
      } else {
        print(
            'Reply Like failed: ${response.statusCode} - ${response.reasonPhrase}');
        print(response.body);
        return false; // Like operation failed
      }
    } catch (error) {
      print("Error: $error");
      return false; // Handle network errors
    }
  }

// Function to find the parent comment based on commentId
  Comment? findParentComment(String commentId) {
    var posts;
    for (var post in posts) {
      for (var comment in post.comments) {
        if (comment.commentId == commentId) {
          return comment;
        }
      }
    }
    return null;
  }

  Future<void> saveComments(List<dynamic> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final commentsData = comments.map((comment) {
      return json.encode({
        'commentId': comment.commentId,
        'commentText': comment.commentText,
        // Add other comment fields as needed
      });
    }).toList();
    await prefs.setStringList('comments', commentsData);
  }

  void handleReplyClick(Comment comment) {
    setState(() {
      isReplying = true;
      selectedComment = comment;
    });
  }

  void _openReplyBottomSheet(Comment comment, String? commenterName) async {
    final context = this.context;
    if (context != null) {
      await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.8,
            child: Scaffold(
                appBar: AppBar(
                  elevation: 0.0,
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
                  title: Text(
                    'Reply Comments',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromRGBO(0, 0, 0, 1)),
                  ),
                ),
                body: ListView(
                  children: [
                    CommentInputField(
                      postId: widget.postId,
                      postCommentCallback: (String postId, String text) async {
                        // Add a new reply comment
                        CommentReplyModel? result = await CommentReplyService()
                            .addReplyComments(postId, comment.commentId, text);
                        bool success = result != null;
                        if (success) {
                          final newReplyComments =
                              List<Comment>.from(comment.replyComments);

                          final newReplyComment = Comment(
                            profileImage:
                                '${imagespath.baseUrl}${result.commentdetails?.profileImage ?? ""}',
                            isLiked: false,
                            commenterId: result.commentdetails!.sId!,
                            firstName: result.commentdetails!.firstname!,
                            commentText: result.text!,
                            isPostComment: false,
                            commentId: result.commentId!,
                          );

                          setState(() {
                            comment.replyComments = newReplyComments;
                            isReplying = false;
                            selectedComment = null;
                          });
                        }

                        Navigator.of(context).pop();
                      },
                      initialText:
                          commenterName != null ? '@$commenterName ' : '',
                      showLikeButton: true,
                      isLiked: comment.isLiked,
                      onLikePressed: () {
                        _toggleLike(comment);
                      },
                    ),
                  ],
                )),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Column(
      children: widget.comments.map((comment) {
        List<Widget> commentWidgets = []; // Initialize as an empty List<Widget>
        if (comment != null) {
          commentWidgets.add(
            Container(
              padding: const EdgeInsets.only(left: 0, top: 15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        '${imagespath.baseUrl}${comment.profileImage}'),
                    radius: 20.0,
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.firstName,
                        style: GoogleFonts.roboto(
                          fontSize: 14.6,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(25, 41, 92, 1),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        comment.commentText,
                        style: GoogleFonts.roboto(
                          fontSize: 14.6,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromRGBO(153, 161, 190, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
          commentWidgets.add(const SizedBox(height: 6.0));
          commentWidgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  if (comment.isPostComment)
                    InkWell(
                      onTap: () async {
                        bool liked = await handleLike(
                          comment,
                          null,
                        );

                        if (liked) {
                        } else {}
                      },
                      child: Row(
                        children: [
                          Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            color: comment.isLiked
                                ? Colors.red
                                : const Color(0xFF60709D),
                            size: 22.0,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'Like...',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromRGBO(96, 112, 157, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 20), // Add gap
                  if (comment.isPostComment)
                    InkWell(
                      onTap: () {
                        _openReplyBottomSheet(comment, comment.firstName);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Text(
                          "Reply",
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(96, 112, 157, 1),
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      const SizedBox(
                          width:
                              8), // Add a smaller gap between "Reply" and "View Replies"
                      if (comment.replyComments.isNotEmpty)
                        InkWell(
                          onTap: () {
                            setState(() {
                              widget.showReplies = !widget.showReplies;
                            });
                            getComment(widget.postId);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              widget.showReplies
                                  ? "Hide Replies"
                                  : "View Replies",
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromRGBO(153, 161, 190, 1),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
          if (widget.showReplies) {
            if (comment.replyComments?.isNotEmpty != null &&
                comment.replyComments.isNotEmpty) {
              List<Widget> replyCommentWidgets =
                  comment.replyComments.map<Widget>((replyComment) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0), // Add right padding
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start, // Adjusted to start
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage('${replyComment.profileImage}'),
                            radius: 15.0,
                          ),
                          const SizedBox(width: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                replyComment.firstName,
                                style: GoogleFonts.roboto(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                replyComment.commentText,
                                style: GoogleFonts.roboto(
                                  fontSize: 14.6,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF99A1BE),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Button for liking a reply comment
                        InkWell(
                          onTap: () async {
                            Map<String, dynamic> result =
                                await likeReplyComment(widget.postId,
                                    comment.commentId, replyComment.commentId);
                            setState(() {
                              replyComment.isLiked =
                                  result['message'] == "liked your Comment";
                              replyComment.likedCount =
                                  result['result']['totallikesofcomments'] ?? 0;
                            });
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 30.0), // Add left padding(
                                child: Icon(
                                  replyComment.isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border_outlined,
                                  color: replyComment.isLiked
                                      ? Colors.red
                                      : const Color(0xFF60709D),
                                  size: 22.0,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Text("${replyComment?.likedCount}"),
                              Text(
                                'Like',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color.fromRGBO(96, 112, 157, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20), // Add gap
                        // Button for replying to a reply comment
                        InkWell(
                          onTap: () {
                            // Add your Reply button logic here for reply comments
                            _openReplyBottomSheet(
                                replyComment, replyComment.firstName);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: Text(
                              "Reply",
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromRGBO(96, 112, 157, 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList();

              // Add the replyCommentWidgets to the commentWidgets list
              commentWidgets.addAll(replyCommentWidgets);
            }
          } else {
            Null;
          }
          // Display child comments if they exist
        }
        return Column(children: commentWidgets);
      }).toList(),
    );
  }
}

class CommentInputField extends StatefulWidget {
  final String postId;
  final Function(String, String) postCommentCallback;
  final String? initialText;
  final bool showLikeButton; // New parameter to show/hide the like button
  final bool isLiked; // New parameter to determine the liked status
  final Function()
      onLikePressed; // Callback for when the like button is pressed

  CommentInputField({
    required this.postId,
    required this.postCommentCallback,
    this.initialText,
    this.showLikeButton = false,
    this.isLiked = false,
    required this.onLikePressed,
  });

  @override
  _CommentInputFieldState createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;

  @override
  void initState() {
    super.initState();

    // Set the initial text in the input field
    if (widget.initialText != null) {
      _commentController.text = widget.initialText!;
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return Column(
      children: [
        const Divider(),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                  ),
                  onChanged: (text) {
                    setState(() {
                      _isCommenting = text.isNotEmpty;
                    });
                  },
                ),
              ),
              if (_isCommenting)
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.green,
                  ),
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      widget.postCommentCallback(
                        // Pass two arguments here
                        widget.postId,
                        _commentController.text,
                      );
                      _commentController.clear();
                      setState(() {
                        _isCommenting = false;
                      });
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CommentBottomSheet extends StatefulWidget {
  final Post post;
  final Function(String, String) postCommentCallback;
  final Function toggleCommentSection;
  final List<Post> posts;

  CommentBottomSheet({
    required this.post,
    required this.postCommentCallback,
    required this.toggleCommentSection,
    required this.posts,
  });

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        title: Text(
          'Comments',
          textAlign: TextAlign.start,
          style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color.fromRGBO(0, 0, 0, 1)),
        ),
      ),
      body: ListView(
        children: [
          CommentSection(
            comments: widget.post.comments,
            postId: widget.post.id,
            postCommentCallback: widget.postCommentCallback,
            posts: [],
          ),
          const Divider(),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.only(left: 20.w),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment...',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Colors.green,
              ),
              onPressed: () {
                final text = _commentController.text;
                if (text.isNotEmpty) {
                  widget.postCommentCallback(widget.post.id, text);
                  _commentController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CommentDatabaseHelper {
  static const _databaseName = 'comment_database.db';
  static const _databaseVersion = 1;

  CommentDatabaseHelper._privateConstructor();
  static final CommentDatabaseHelper instance =
      CommentDatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    print('Database path: $path');
    return await openDatabase(
      '$path/$_databaseName',
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print('Creating the comments table');
    await db.execute('''
    CREATE TABLE comments (
      id TEXT PRIMARY KEY,
      isLiked INTEGER
    )
  ''');
  }
}
