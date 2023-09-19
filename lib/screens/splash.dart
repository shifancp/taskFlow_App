import 'package:task_flow_app/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash_Screen extends StatefulWidget {
  const Splash_Screen({super.key});

  @override
  State<Splash_Screen> createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  @override
  void initState() {
    super.initState();
    navigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(image: AssetImage('assets/images/splash.gif')),
      ),
    );
  }

  Future<void> navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final _isloggedin = prefs.getBool(SAVE_KEY);

    await Future.delayed(
        Duration(seconds: 5)); // Show splash screen for 2 seconds

    if (_isloggedin == null || _isloggedin == false) {
      Navigator.pushReplacementNamed(context, '/signup');
    } else {
      await Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}
  // Future<void> goToLogin() async {
  //   await Future.delayed(Duration(seconds: 10));
  //   Navigator.pushReplacementNamed(context, '/signup');
  // }

  // Future<void> checkLoggedIn() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final _isloggedin = prefs.getBool(SAVE_KEY);
  //   if (_isloggedin == null || _isloggedin == false) {
  //     goToLogin();
  //   } else {
  //     await Navigator.of(context).pushReplacementNamed('/home');
  //   }
  // }
// }
