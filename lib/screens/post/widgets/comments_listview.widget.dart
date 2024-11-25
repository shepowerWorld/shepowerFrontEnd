import 'package:flutter/material.dart';
import 'package:Shepower/screens/post/models/comment.model.dart';

class CommentsView extends StatelessWidget {
  final List<Comment> comments;
  const CommentsView({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        primary: false,
        shrinkWrap: true,
        itemCount: comments.length,
        itemBuilder: (context, i) {
          Comment item = comments[i];
          return CommentCard(comment: item);
        });
  }
}

class CommentCard extends StatelessWidget {
  final Comment comment;
  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    if (comment.text == null || comment.text == "") {
      return const SizedBox.shrink();
    }

    return Container(
      child: Text(comment.text!),
    );
  }
}
