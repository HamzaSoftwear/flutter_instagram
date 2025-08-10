 
 
 
 
 
 
 import 'package:flutter/material.dart';
import 'package:flutter_instagram/firebase_services/auth.dart';
import 'package:flutter_instagram/models/user.dart';


class UserProvider with ChangeNotifier {
  UserDate? _userData;
  UserDate? get getUser => _userData;
  
  refreshUser() async {
    UserDate userData = await AuthMethods().getUserDetails();
    _userData = userData;
    notifyListeners();
  }
 }