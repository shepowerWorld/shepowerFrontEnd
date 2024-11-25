import 'dart:convert';

import 'package:Shepower/service.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class SosComment {
  final String id;
  final String userId;
  final String sosId;
  final String commentSos;
  final int? ratingsCount;
  final int? ratings;
  final String reviews;
  final String createdAt;
  final String updatedAt;
  final List<Reply> replies;
  final List<UserDetails> citileaderUserDetails;

  SosComment({
    required this.id,
    required this.userId,
    required this.sosId,
    required this.commentSos,
    required this.ratingsCount,
    required this.ratings,
    required this.reviews,
    required this.createdAt,
    required this.updatedAt,
    required this.replies,
    required this.citileaderUserDetails,
  });

  factory SosComment.fromJson(Map<String, dynamic> json) {
    final List<UserDetails> citizenUserDetails =
        (json['citizenUserDetails'] as List<dynamic>)
            .map((userJson) => UserDetails.fromJson(userJson))
            .toList();

    final List<UserDetails> leaderUserDetails =
        (json['leaderUserDetails'] as List<dynamic>)
            .map((userJson) => UserDetails.fromJson(userJson))
            .toList();

    final List<UserDetails> citileaderUserDetails = [
      ...citizenUserDetails,
      ...leaderUserDetails
    ];

    return SosComment(
      id: json['_id'] ?? "",
      userId: json['user_id'] ?? "",
      sosId: json['sosId'] ?? "",
      commentSos: json['commentSos'] ?? "",
      ratingsCount: json['ratingsCount'] as int?,
      ratings: json['ratings'] as int?,
      reviews: json['reviews'] ?? '',
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      replies: (json['replies'] as List<dynamic>)
              .map((replyJson) => Reply.fromJson(replyJson))
              .toList() ??
          [],
      citileaderUserDetails: citileaderUserDetails,
    );
  }
}

class UserDetails {
  final String id;
  final String firstname;
  final String profileImg;

  UserDetails({
    required this.id,
    required this.firstname,
    required this.profileImg,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['_id'] ?? "",
      firstname: json['firstname'] ?? "",
      profileImg: json['profile_img'] ?? "",
    );
  }
}

class Reply {
  final String id;
  final String userId;
  final String sosId;
  final String commentSos;
  final int? ratingsCount;
  final int? ratings;
  final String reviews;
  final String commentId;
  final String createdAt;
  final String updatedAt;
  final List<UserDetails> citileaderUserDetails;

  Reply({
    required this.id,
    required this.userId,
    required this.sosId,
    required this.commentSos,
    required this.ratingsCount,
    required this.ratings,
    required this.reviews,
    required this.commentId,
    required this.createdAt,
    required this.updatedAt,
    required this.citileaderUserDetails,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    final List<UserDetails> citizenUserDetails =
        (json['citizenUserDetails'] as List<dynamic>)
            .map((userJson) => UserDetails.fromJson(userJson))
            .toList();

    final List<UserDetails> leaderUserDetails =
        (json['leaderUserDetails'] as List<dynamic>)
            .map((userJson) => UserDetails.fromJson(userJson))
            .toList();

    final List<UserDetails> citileaderUserDetails = [
      ...citizenUserDetails,
      ...leaderUserDetails
    ];

    return Reply(
      id: json['_id'] ?? " ",
      userId: json['user_id'] ?? " ",
      sosId: json['sosId'] ?? " ",
      commentSos: json['commentSos'] ?? " ",
      ratingsCount: json['ratingsCount'] as int?,
      ratings: json['ratings'] as int?,
      reviews: json['reviews'] ?? '',
      commentId: json['comment_id'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      citileaderUserDetails: citileaderUserDetails,
    );
  }
}

class CommentScreen extends StatefulWidget {
  final String citizensosis;

  CommentScreen({Key? key, required this.citizensosis}) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Comment'),
      ),
      body: CommentForm(citizensosis: widget.citizensosis),
    );
  }
}

class CommentForm extends StatefulWidget {
  final String citizensosis;

  CommentForm({
    required this.citizensosis,
  });

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  TextEditingController _commentController = TextEditingController();
  TextEditingController _replyController = TextEditingController();
  late Future<List<SosComment>> _commentsFuture;
  String? _replyToCommentId;
  String? _replyusername;
  Map<String, bool> _showReplies = {};

  @override
  void initState() {
    super.initState();
    _commentsFuture = getcomment(widget.citizensosis);
  }


    bool hasReplies(SosComment comment) {
    for (var reply in comment.replies) {
      if (reply.citileaderUserDetails.isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: FutureBuilder<List<SosComment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('No Comments Available'));
                } else {
                  final List<SosComment> comments = snapshot.data!;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final SosComment comment = comments[index];
                      final bool isRepliesVisible =
                          _showReplies[comment.id] ?? false;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                    '${imagespath.baseUrl}${comment.citileaderUserDetails[0].profileImg}',
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment
                                            .citileaderUserDetails[0].firstname,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      ExpandableText(
                                        comment.commentSos,
                                        expandText: 'show more',
                                        collapseText: 'show less',
                                        maxLines: 2,
                                        linkColor: Colors.pink,
                                        animation: true,
                                        collapseOnTextTap: true,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 0, top: 5),
                                            child: Text(
                                              formatNotificationTime(
                                                  comment.createdAt),
                                              style: GoogleFonts.montserrat(
                                                fontWeight: FontWeight.w300,
                                                color: Colors.black,
                                                fontSize: 12,
                                                height: 1.21875,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: hasReplies(comment),
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _showReplies[comment.id] =
                                                      !isRepliesVisible;
                                                });
                                              },
                                              child: Text(
                                                isRepliesVisible
                                                    ? 'hide replies'
                                                    : 'show replies',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _replyController.text =
                                          'Replying to: ${comment.commentSos}';
                                      _replyToCommentId = comment.id;
                                      _replyusername = comment
                                          .citileaderUserDetails[0].firstname;
                                    });
                                  },
                                  child: const Text('Reply'),
                                ),
                              ],
                            ),
                          ),
                          if (isRepliesVisible && comment.replies.isNotEmpty)
                            for (var reply in comment.replies)
                              if (reply.citileaderUserDetails.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 60.0, top: 5, bottom: 5, right: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(
                                          '${imagespath.baseUrl}${reply.citileaderUserDetails[0].profileImg}',
                                        ),
                                      ),
                                      const SizedBox(width: 8.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              reply.citileaderUserDetails[0]
                                                  .firstname,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                            ExpandableText(
                                              reply.commentSos,
                                              expandText: 'show more',
                                              collapseText: 'show less',
                                              maxLines: 2,
                                              linkColor: Colors.pink,
                                              animation: true,
                                              collapseOnTextTap: true,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 0, top: 5),
                                              child: Text(
                                                formatNotificationTime(
                                                    reply.createdAt),
                                                style: GoogleFonts.montserrat(
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                  height: 1.21875,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _replyController.text =
                                                'Replying to: ${reply.commentSos}';
                                            _replyToCommentId = reply.id;
                                            _replyusername = reply
                                                    .citileaderUserDetails
                                                    .isNotEmpty
                                                ? reply.citileaderUserDetails[0]
                                                    .firstname
                                                : 'Unknown User';
                                          });
                                        },
                                        child: const Text('Reply'),
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
          if (_replyToCommentId != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Replying to: ${_replyusername}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyToCommentId = null;
                        _commentsFuture = getcomment(widget.citizensosis);
                      });
                    },
                    child: Icon(Icons.close),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 3.0, left: 3, right: 3),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add Comment...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendComment(),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _sendComment,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.send,
                        color: Colors.pink,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendComment() async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');

    String comment = _commentController.text;

    print('__replyToCommentId$_replyToCommentId');

    if (_replyToCommentId != null) {
      String comments = _commentController.text;

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request = http.Request(
          'POST', Uri.parse('${ApiConfig.baseUrl}replyCommentsSos'));
      request.body = json.encode({
        "user_id": id,
        "comment_id": _replyToCommentId,
        "sosId": widget.citizensosis,
        "commentSos": comments
      });
      print(request.body);
      request.headers.addAll(headers);

      http.StreamedResponse replyResponse = await request.send();

      if (replyResponse.statusCode == 200) {
        print(await replyResponse.stream.bytesToString());
        setState(() {
          _commentsFuture = getcomment(widget.citizensosis);
        });
        _commentController.clear();
      } else {
        print(replyResponse.reasonPhrase);
      }
    } else {
      // If not replying to a comment, call the commentsSos API
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accesstoken'
      };
      var request =
          http.Request('POST', Uri.parse('${ApiConfig.baseUrl}commentsSos'));
      request.body = json.encode(
          {"user_id": id, "sosId": widget.citizensosis, "commentSos": comment});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        // After sending the comment, refresh the comments list
        setState(() {
          _commentsFuture = getcomment(widget.citizensosis);
        });

        _commentController.clear();
      } else {
        print(response.reasonPhrase);
      }
    }
  }

  Future<List<SosComment>> getcomment(String citizensosis) async {
    final storage = FlutterSecureStorage();
    String? id = await storage.read(key: '_id');
    String? accesstoken = await storage.read(key: 'accessToken');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request =
        http.Request('GET', Uri.parse('${ApiConfig.baseUrl}getSosComments'));
    request.body = json.encode({"sosId": widget.citizensosis});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final parsed = jsonDecode(responseBody);
      final comments = parsed['response'] as List<dynamic>;
      return comments
          .map<SosComment>((json) => SosComment.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
