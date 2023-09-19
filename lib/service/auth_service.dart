import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthClass {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> googleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        try {
          // ignore: unused_local_variable
          UserCredential userCredential =
              await auth.signInWithCredential(credential);
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        } catch (e) {
          final snackbar = SnackBar(
            content: Text(e.toString()),
            elevation: 10,
            backgroundColor: Colors.red,
          );
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      } else {
        final snackbar = SnackBar(
          content: Text(
              'Something went wrong! Not able to sign in. Please try again'),
          elevation: 10,
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } catch (e) {
      final snackbar = SnackBar(
        content: Text(e.toString()),
        elevation: 10,
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }
}
