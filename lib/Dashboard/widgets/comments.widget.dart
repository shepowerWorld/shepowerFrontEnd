import 'package:Shepower/Dashboard/Explorescreen.dart';
import 'package:flutter/material.dart';

class ReplyCommentWidget extends StatelessWidget {
  final List<Comment> replyComments;
  const ReplyCommentWidget({Key? key, required this.replyComments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (replyComments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
        children: replyComments.map((Comment item) {
      return Text(item.commentText);
    }).toList());
  }
}
