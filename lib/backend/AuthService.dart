import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late SharedPreferences prefs;

  AuthService() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> handleSignin(
    String username,
    String password,
    BuildContext context,
    String userType,
  ) async {
    try {
      print(userType);
      QuerySnapshot query = await _firestore
          .collection("user")
          .where("username", isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No user found with this username."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final userDoc = query.docs.first;
      String fetchedUserType = userDoc["userType"];

      if (fetchedUserType != userType) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Access Denied: Only administrators are allowed to sign in."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      String email = userDoc["email"];
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sign in failed. Please try again."),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      await prefs.setString("auth", user.uid);
      await prefs.setString("userType", userType);

      print("Logged in as: ${user.email}");

      Navigator.of(context).pushNamedAndRemoveUntil(
          '/dashboard', (Route<dynamic> route) => false);
    } catch (e) {
      print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred during sign in. Please try again."),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
