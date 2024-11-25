import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';

import '../../../Dashboard/models/post.model.dart';

class PostCard extends StatelessWidget {
  final Feed post;
  final Function onTapLike;
  final Function onTapComment;
  final Function onTapShare;
  final Function onTapProfileImage;
  final Function onTapLikedPeople;
  final Function onTapBlock;
  final Function onTapDelete;

  const PostCard(
      {super.key,
      required this.post,
      required this.onTapLike,
      required this.onTapComment,
      required this.onTapShare,
      required this.onTapLikedPeople,
      required this.onTapBlock,
      required this.onTapDelete,
      required this.onTapProfileImage});

  @override
  Widget build(BuildContext context) {
    bool isCitizen = post.profileID?.startsWith('citizen') ?? false;

    Widget _buildProfileHeader() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              '${imagespath.baseUrl}${post.userProfileImg}',
            ),
            radius: 40,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(post.userName ?? "",
                      style: TextStyle(
                          color: !isCitizen ? Colors.pink : Colors.black)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget _buildDescription() {
      return Container(
        width: double.infinity,
        child: Text(post.postDiscription ?? ""),
      );
    }

    Widget _buildPostImage() {
      return Image.network(
        '${imagespath.baseUrl}${post.post}',
        width: double.infinity,
        fit: BoxFit.fill,
      );
    }

    Widget _buildBottomMenuItem(
        {required Widget iconWidget, int? count, required Function onTap}) {
      return GestureDetector(
          onTap: () => onTap(),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [Container(child: iconWidget), Text("${count ?? 0}")]));
    }

    Widget _buildPostBottomRow() {
      return Container(
          width: double.infinity,
          child: Row(children: [
            Container(
              height: 50,
              width: 80,
              color: Colors.blue,
            ),
            const Spacer(),
            _buildBottomMenuItem(
                iconWidget: (post.isPostLiked ?? false)
                    ? const Icon(Icons.favorite, color: Colors.red)
                    : const Icon(Icons.favorite_border_outlined),
                onTap: () => onTapLike(),
                count: post.totallikesofpost),
            _buildBottomMenuItem(
                iconWidget:
                    Image.asset('assets/explore/comment.png', width: 25),
                onTap: () => onTapComment(),
                count: post.totalComments),
            _buildBottomMenuItem(
                iconWidget: Image.asset('assets/explore/shar.png', width: 25),
                onTap: () => onTapShare())
          ]));
    }

    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProfileHeader(),
        _buildDescription(),
        _buildPostImage(),
        _buildPostBottomRow(),
      ],
    ));
  }
}
