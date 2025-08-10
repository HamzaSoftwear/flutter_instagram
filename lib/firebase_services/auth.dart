import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_instagram/firebase_services/storage.dart';
import 'package:flutter_instagram/models/user.dart';
import 'package:flutter_instagram/shared/snackbar.dart';


class AuthMethods {
  register({
    required emailll,
    required passworddd,
    required context,
    required titleee,
    required usernameee,
    required imgName,
    required imgPath,
  }) async {
    String message = "ERROR => Not starting the code";

    try {
      // Validate inputs
      if (emailll.isEmpty || passworddd.isEmpty || titleee.isEmpty || usernameee.isEmpty) {
        showSnackBar(context, "All fields are required");
        return;
      }

      // Make profile image optional
      if (imgName == null || imgPath == null) {
        print("No profile image selected, using default");
      }

      print("Starting registration for: $emailll");
      if (imgName != null && imgPath != null) {
        print("Image name: $imgName, Image size: ${imgPath.length} bytes");
      } else {
        print("No image provided");
      }

      // Step 1: Create Firebase Auth user
      print("Creating user account...");
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailll,
        password: passworddd,
      );

      print("Firebase Auth successful, UID: ${credential.user!.uid}");
      message = "ERROR => Registered only";

      // Step 2: Handle image upload (optional now)
      String urlll = "";
      if (imgName != null && imgPath != null) {
        try {
          urlll = await getImgURL(
              imgName: imgName,
              imgPath: imgPath,
              folderName: 'profilePics/${credential.user!.uid}');
          print("Profile image uploaded successfully: $urlll");
        } catch (e) {
          print("Failed to upload profile image: $e");
          urlll = ""; // Use empty string if upload fails
        }
      } else {
        print("Using default profile image");
      }

      // Step 3: Create user document
      print("Setting up user profile...");
      CollectionReference users =
          FirebaseFirestore.instance.collection('userSSS');

      UserDate userr = UserDate(
          email: emailll,
          password: "", // Don't store password in Firestore
          title: titleee,
          username: usernameee,
          profileImg: urlll,
          uid: credential.user!.uid,
          followers: [],
          following: []);

      print("Creating user document...");
      await users
          .doc(credential.user!.uid)
          .set(userr.convert2Map());

      print("User document created successfully");
      message = "Account created successfully!";
      
      // Ensure user is signed in after registration
      if (FirebaseAuth.instance.currentUser == null) {
        print("User not signed in after registration, signing in...");
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailll,
          password: passworddd,
        );
        print("User signed in successfully after registration");
      }
      
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      showSnackBar(context, "ERROR :  ${e.code} ");
      throw e; // Re-throw to be caught by the calling function
    } catch (e) {
      print("Unexpected error: $e");
      showSnackBar(context, "An unexpected error occurred: $e");
      throw e; // Re-throw to be caught by the calling function
    }

    showSnackBar(context, message);
  }

  signIn({required emailll, required passworddd, required context}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailll, password: passworddd);
      return true; // Return true on successful login
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
      return false; // Return false on error
    } catch (e) {
      print(e);
      showSnackBar(context, "An unexpected error occurred");
      return false; // Return false on error
    }
  }

  // functoin to get user details from Firestore (Database)
  Future<UserDate> getUserDetails() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('userSSS')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return UserDate.convertSnap2Model(snap);
  }
}