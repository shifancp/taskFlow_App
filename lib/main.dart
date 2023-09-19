import 'package:demo_app2/screens/add_screen.dart';
import 'package:demo_app2/screens/home_screen.dart';
import 'package:demo_app2/screens/signupscreen.dart';
import 'package:demo_app2/screens/splash.dart';
import 'package:demo_app2/screens/update.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/account_details.dart';

const SAVE_KEY = 'isLoggedIn';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'RajDhani'),
      home: Splash_Screen(),
      routes: {
        '/signup': (context) => SignUp(),
        '/home': (context) => Home_Screen(),
        '/addscreen': (context) => Add_Screen(),
        '/update': (context) => Update_Screen(),
        '/account': (context) => Acc_details(),
      },
    );
  }
}
