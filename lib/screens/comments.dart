// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_instagram/firebase_services/firestore.dart';
import 'package:flutter_instagram/provider/user_provider.dart';
import 'package:flutter_instagram/shared/colors.dart';
import 'package:flutter_instagram/shared/contants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CommentsScreen extends StatefulWidget {
  // data of clicked post
  final Map data;
  bool showTextField = true;
  CommentsScreen({Key? key, required this.data, required this.showTextField})
      : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Comments',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('postSSS')
                .doc(widget.data["postId"])
                .collection("commentSSS")
                .orderBy("dataPublished", descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(
                  color: Colors.white,
                );
              }

              return Expanded(
                child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return Container(
                      margin: EdgeInsets.only(bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 12),
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromARGB(125, 78, 91, 110),
                                ),
                                child: CircleAvatar(
                                  backgroundImage: (data["profilePic"] != null && data["profilePic"].isNotEmpty)
                                      ? NetworkImage(data["profilePic"])
                                      : null,
                                  backgroundColor: Colors.grey[300],
                                  radius: 26,
                                  child: (data["profilePic"] == null || data["profilePic"].isEmpty)
                                      ? Icon(
                                          Icons.person,
                                          size: 26,
                                          color: Colors.grey[600],
                                        )
                                      : null,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(data["username"] ?? "Unknown User",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17)),
                                      SizedBox(
                                        width: 11,
                                      ),
                                      Text(data["textComment"] ?? "",
                                          style: const TextStyle(fontSize: 16))
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                      DateFormat('MMM d, ' 'y').format(
                                          data["dataPublished"] ?? DateTime.now()),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ))
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                              onPressed: () {}, icon: Icon(Icons.favorite))
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          widget.showTextField
              ? Container(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(125, 78, 91, 110),
                        ),
                        child: CircleAvatar(
                          backgroundImage: (userData!.profileImg != null && userData!.profileImg.isNotEmpty)
                              ? NetworkImage(userData!.profileImg)
                              : null,
                          backgroundColor: Colors.grey[300],
                          radius: 26,
                          child: (userData!.profileImg == null || userData!.profileImg.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 26,
                                  color: Colors.grey[600],
                                )
                              : null,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                            controller: commentController,
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            decoration: decorationTextfield.copyWith(
                                hintText: "Comment as  ${userData.username}  ",
                                suffixIcon: IconButton(
                                    onPressed: () async {
                                      await FirestoreMethods().uploadComment(
                                          commentText: commentController.text,
                                          postId: widget.data["postId"],
                                          profileImg: userData.profileImg,
                                          username: userData.username,
                                          uid: userData.uid);

                                      commentController.clear();
                                    },
                                    icon: Icon(Icons.send)))),
                      ),
                    ],
                  ),
                )
              : Text("")
        ],
      ),
    );
  }
}