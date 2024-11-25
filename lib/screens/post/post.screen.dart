import 'package:flutter/material.dart';
import 'package:Shepower/screens/post/models/comment.model.dart';
import 'package:Shepower/screens/post/models/post_like.model.dart';
import 'package:Shepower/services/post.service.dart';

import '../../Dashboard/models/post.model.dart';
import 'widgets/post_card.widget.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final postService = PostService();
  List<Feed> posts = [];
  List<Comment> comments = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    List<Feed> list = await postService.getPosts();
    setState(() {
      posts = list;
    });
  }

  onPostLike(String postId, int postIndex) async {
    PostLikeModel? like = await postService.likePost(postId);
    if (like == null) {
      return;
    }
    setState(() {
      posts[postIndex].isPostLiked = like.isPostLiked;
      posts[postIndex].totallikesofpost = like.totallikesofpost;
      posts[postIndex].likedpeopledata = like.likesofposts;
    });
  }

//  onTapComments()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("POSTS"),
        ),
        body: Container(
          child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: posts.length,
              itemBuilder: (context, i) {
                Feed item = posts[i];
                return PostCard(
                  post: item,
                  onTapLike: () => onPostLike(item.sId!, i),
                  onTapComment: () {},
                  onTapShare: () {},
                  onTapProfileImage: () {},
                  onTapLikedPeople: () {},
                  onTapBlock: () {},
                  onTapDelete: () {},
                );
              }),
        ));
  }
}
