import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_instagram/firebase_services/storage.dart';
import 'package:flutter_instagram/models/post.dart';
import 'package:flutter_instagram/shared/snackbar.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  uploadPost(
      {required imgName,
      required imgPath,
      required description,
      required profileImg,
      required username,
      required context}) async {
    String message = "ERROR => Not starting the code";

    try {
      print("Starting post upload process...");
      
      // Upload image to Firebase Storage
      String urlll = await getImgURL(
          imgName: imgName,
          imgPath: imgPath,
          folderName: 'imgPosts/${FirebaseAuth.instance.currentUser!.uid}');

      print("Image uploaded successfully: $urlll");

      // Create post in Firestore
      CollectionReference posts =
          FirebaseFirestore.instance.collection('postSSS');

      String newId = const Uuid().v1();

      PostData postt = PostData(
          datePublished: DateTime.now(),
          description: description,
          imgPost: urlll,
          likes: [],
          profileImg: profileImg,
          postId: newId,
          uid: FirebaseAuth.instance.currentUser!.uid,
          username: username);

      print("Creating post document with ID: $newId");
      
      await posts.doc(newId).set(postt.convert2Map());
      print("Post created successfully in Firestore");

      message = "Posted successfully ♥ ♥";
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code}");
      showSnackBar(context, "Authentication Error: ${e.code}");
    } catch (e) {
      print("General Error: $e");
      showSnackBar(context, "Error: $e");
    }

    showSnackBar(context, message);
  }

  uploadComment(
      {required commentText,
      required postId,
      required profileImg,
      required username,
      required uid}) async {
    if (commentText.isNotEmpty) {
      String commentId = const Uuid().v1();
      await FirebaseFirestore.instance
          .collection("postSSS")
          .doc(postId)
          .collection("commentSSS")
          .doc(commentId)
          .set({
        "profilePic": profileImg,
        "username": username,
        "textComment": commentText,
        "dataPublished": DateTime.now(),
        "uid": uid,
        "commentId": commentId
      });
    } else {
      print("emptyyyyyyyy");
    }
  }

  toggleLike({required Map postData}) async {
    try {
      if ((postData["likes"] ?? []).contains(FirebaseAuth.instance.currentUser!.uid)) {
        await FirebaseFirestore.instance
            .collection("postSSS")
            .doc(postData["postId"])
            .update({
          "likes":
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      } else {
        await FirebaseFirestore.instance
            .collection("postSSS")
            .doc(postData["postId"])
            .update({
          "likes":
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}