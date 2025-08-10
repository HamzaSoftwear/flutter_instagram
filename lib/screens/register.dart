// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/firebase_services/auth.dart';
import 'package:flutter_instagram/responsive/mobile.dart';
import 'package:flutter_instagram/responsive/responsive.dart';
import 'package:flutter_instagram/responsive/web.dart';
import 'package:flutter_instagram/screens/sign_in.dart';
import 'package:flutter_instagram/shared/colors.dart';
import 'package:flutter_instagram/shared/contants.dart';
import 'package:flutter_instagram/shared/snackbar.dart';
import 'package:image_picker/image_picker.dart';


import 'dart:io';

import 'package:path/path.dart' show basename;

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isVisable = true;
  Uint8List? imgPath;
  String? imgName;

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final usernameController = TextEditingController();

  final titleController = TextEditingController();

  uploadImage2Screen(ImageSource source) async {
    Navigator.pop(context);
    final XFile? pickedImg = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512, // Compress image to max 512px width
      maxHeight: 512, // Compress image to max 512px height
      imageQuality: 70, // Reduce quality to 70% for faster upload
    );
    try {
      if (pickedImg != null) {
        imgPath = await pickedImg.readAsBytes();
        if (imgPath != null && imgPath!.isNotEmpty) {
          setState(() {
            imgName = basename(pickedImg.path);
            int random = Random().nextInt(9999999);
            imgName = "$random$imgName";
            print("Image selected: $imgName, size: ${imgPath!.length} bytes");
          });
        } else {
          showSnackBar(context, "Failed to load image");
        }
      } else {
        print("NO img selected");
      }
    } catch (e) {
      print("Error => $e");
      showSnackBar(context, "Error loading image: $e");
    }
  }

  showmodel() {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(22),
          height: 170,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  await uploadImage2Screen(ImageSource.camera);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.camera,
                      size: 30,
                    ),
                    SizedBox(
                      width: 11,
                    ),
                    Text(
                      "From Camera",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 22,
              ),
              GestureDetector(
                onTap: () {
                  uploadImage2Screen(ImageSource.gallery);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.photo_outlined,
                      size: 30,
                    ),
                    SizedBox(
                      width: 11,
                    ),
                    Text(
                      "From Gallery",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  clickOnRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      
      try {
        // Show immediate feedback
        showSnackBar(context, "Creating account...");
        
        // Use default image for now
        String defaultImageUrl = "https://via.placeholder.com/150";
        
        await AuthMethods().register(
            emailll: emailController.text,
            passworddd: passwordController.text,
            context: context,
            titleee: titleController.text,
            usernameee: usernameController.text,
            imgName: "default.jpg",
            imgPath: Uint8List.fromList([0])).timeout(
          Duration(seconds: 15),
          onTimeout: () {
            throw Exception("Registration timed out. Please try again.");
          },
        );
            
        setState(() {
          isLoading = false;
        });
        
        if (!mounted) return;
        
        // Force a small delay to ensure Firebase Auth state is updated
        await Future.delayed(Duration(milliseconds: 1000));
        
        if (!mounted) return;
        
        // Check if user is actually signed in
        if (FirebaseAuth.instance.currentUser != null) {
          print("User is signed in, navigating to main screen");
          print("User UID: ${FirebaseAuth.instance.currentUser!.uid}");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Resposive(
                      myWebScreen: WebScerren(),
                      myMobileScreen: MobileScerren(),
                    )),
          );
        } else {
          print("User not signed in, showing login screen");
          print("Current user: ${FirebaseAuth.instance.currentUser}");
          showSnackBar(context, "Registration successful! Please sign in.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        showSnackBar(context, "Registration failed: $e");
      }
    } else {
      showSnackBar(context, "Please fill all required fields");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    emailController.dispose();
    passwordController.dispose();

    usernameController.dispose();

    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        title: Text("Register"),
        elevation: 0,
        // backgroundColor: appbarGreen,
      ),
      body: Center(
        child: Padding(
          padding: widthScreen > 600
              ? EdgeInsets.symmetric(horizontal: widthScreen * .3)
              : const EdgeInsets.all(33.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile image section - removed for now
                  // Users can add photos later in their profile settings
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "You can add a profile photo later in settings",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(
                    height: 33,
                  ),
                  TextFormField(
                      validator: (value) {
                        return value!.isEmpty ? "Can not be empty" : null;
                      },
                      controller: usernameController,
                      keyboardType: TextInputType.text,
                      obscureText: false,
                      decoration: decorationTextfield.copyWith(
                          hintText: "Enter Your username : ",
                          suffixIcon: Icon(Icons.person))),
                  const SizedBox(
                    height: 22,
                  ),
                  TextFormField(
                      validator: (value) {
                        return value!.isEmpty ? "Can not be empty" : null;
                      },
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      obscureText: false,
                      decoration: decorationTextfield.copyWith(
                          hintText: "Enter Your title : ",
                          suffixIcon: Icon(Icons.person_outline))),
                  const SizedBox(
                    height: 22,
                  ),
                  TextFormField(
                      // we return "null" when something is valid
                      validator: (email) {
                        return email!.contains(RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"))
                            ? null
                            : "Enter a valid email";
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      decoration: decorationTextfield.copyWith(
                          hintText: "Enter Your Email : ",
                          suffixIcon: Icon(Icons.email))),
                  const SizedBox(
                    height: 22,
                  ),
                  TextFormField(
                      onChanged: (password) {},
                      // we return "null" when something is valid
                      validator: (value) {
                        return value!.length < 6
                            ? "Enter at least 6 characters"
                            : null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: isVisable ? true : false,
                      decoration: decorationTextfield.copyWith(
                          hintText: "Enter Your Password : ",
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisable = !isVisable;
                                });
                              },
                              icon: isVisable
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off)))),
                  const SizedBox(
                    height: 33,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      clickOnRegister();
                    },
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            "Register",
                            style: TextStyle(fontSize: 19),
                          ),
                    style: ButtonStyle(
                      // backgroundColor: MaterialStateProperty.all(BTNgreen),
                      padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                  const SizedBox(
                    height: 33,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Do not have an account?",
                          style: TextStyle(fontSize: 18)),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                            );
                          },
                          child: Text('sign in',
                              style: TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.underline))),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}