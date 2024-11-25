import 'package:Shepower/service.dart';
import 'package:flutter/material.dart';

class GroupItem extends StatefulWidget {
  final Group group;

  GroupItem({required this.group});

  @override
  _GroupItemState createState() => _GroupItemState();
}

class _GroupItemState extends State<GroupItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              "${imagespath.baseUrl}${widget.group.groupProfileImg}" ??
                  "",
              height: 120,
              width: 120,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.group.groupName ?? "",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class Group {
  final String groupProfileImg;
  final String groupName;

  Group({required this.groupProfileImg, required this.groupName});
}
