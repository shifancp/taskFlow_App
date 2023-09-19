import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app2/main.dart';
import 'package:demo_app2/service/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  DateTime? birth_date;

  final _bdateController = TextEditingController();

  final _emailMobController = TextEditingController();

  final _PasswordController = TextEditingController();

  final _confirmPassController = TextEditingController();

  String? selectedGender;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AuthClass authClass = AuthClass();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background_sign_up.jpeg',
            fit: BoxFit.cover,
          ),
          Center(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Create an account to continue',
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w900),
                      ),
                      TextFormField(
                        controller: _emailMobController,
                        decoration: InputDecoration(
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Enter Your Email Address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        obscureText: true,
                        controller: _PasswordController,
                        decoration: InputDecoration(
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Enter Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        obscureText: true,
                        controller: _confirmPassController,
                        decoration: InputDecoration(
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Text(
                            'Select Gender?',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          RadioMenuButton(
                              value: 'male',
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value as String?;
                                });
                              },
                              child: Text(
                                'M',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w300),
                              )),
                          RadioMenuButton(
                              value: 'female',
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value as String?;
                                });
                              },
                              child: Text(
                                'F',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w300),
                              )),
                          RadioMenuButton(
                              value: 'other',
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value as String?;
                                });
                              },
                              child: Text(
                                'Other',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w300),
                              )),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _bdateController,
                              decoration: InputDecoration(
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                                filled: true,
                                fillColor: Colors.white,
                                labelText: 'Enter your Birth Date(yyyy-mm-dd)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                _selectDate(context);
                              },
                              icon: Icon(
                                Icons.calendar_month_outlined,
                                size: 30,
                              ))
                        ],
                      ),
                      ElevatedButton.icon(
                          onPressed: () async {
                            SignUp();
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool(SAVE_KEY, true);
                          },
                          icon: Icon(Icons.add),
                          label: Text('Create a free Account')),
                      TextButton(
                          onPressed: () {
                            onClickSignIn(context);
                          },
                          child: Text(
                            'Already have an account?',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )),
                      Container(
                        height: 1,
                        color: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await authClass.googleSignIn(context);
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool(SAVE_KEY, true);
                        },
                        child: Card(
                          color: Colors.tealAccent,
                          elevation: 10,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png',
                                  height: 40,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995), // Set initial date to current date
      firstDate: DateTime(1800),
      lastDate: DateTime(2201),
    );
    if (picked != null && picked != birth_date)
      setState(() {
        birth_date = picked;
        _bdateController.text = "${birth_date!.toLocal()}".split(' ')[0];
      });
  }

  onClickSignIn(
    BuildContext ctx,
  ) async {
    showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _emailMobController.clear();
                              _PasswordController.clear();
                            },
                            icon: Icon(Icons.close)),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Enter Your Credentials',
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w900),
                        ),
                        TextFormField(
                          controller: _emailMobController,
                          decoration: InputDecoration(
                            floatingLabelAlignment:
                                FloatingLabelAlignment.center,
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Enter Your Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextFormField(
                          obscureText: true,
                          controller: _PasswordController,
                          decoration: InputDecoration(
                            floatingLabelAlignment:
                                FloatingLabelAlignment.center,
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Enter Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        ElevatedButton.icon(
                            onPressed: () {
                              signin(context);
                              _emailMobController.clear();
                              _PasswordController.clear();
                            },
                            icon: Icon(
                              Icons.login,
                              size: 30,
                            ),
                            label: Text(
                              'LogIn',
                            )),
                        GestureDetector(
                          onTap: () async {
                            await authClass.googleSignIn(context);
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setBool(SAVE_KEY, true);
                          },
                          child: Card(
                            color: Colors.tealAccent,
                            elevation: 10,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/google.png',
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    'LogIn Using Google',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  void SignUp() async {
    final email = _emailMobController.text;
    final password = _PasswordController.text;
    final confirmpass = _confirmPassController.text;
    if (selectedGender == null || birth_date == null) {
      final snackbar = SnackBar(
        content: Text('Please provide Gender and Date of Birth.'),
        elevation: 10,
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return; // Exit the method if fields are not selected
    }
    if (password == confirmpass) {
      try {
        firebase_auth.UserCredential usercredentials = await firebaseAuth
            .createUserWithEmailAndPassword(email: email, password: password);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(usercredentials.user?.uid)
            .set({
          'birthDate': birth_date?.toUtc(),
          'gender': selectedGender,
        });
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        _emailMobController.clear();
        _PasswordController.clear();
        _confirmPassController.clear();
      } catch (e) {
        String errorMessage = 'An error occurred';
        if (e is firebase_auth.FirebaseAuthException) {
          errorMessage = e.message ?? 'An error occurred';
        }
        final snackbar = SnackBar(
          content: Text(errorMessage),
          elevation: 10,
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } else {
      final snackbar = SnackBar(
        content: Text('Passwords don\'t match'),
        elevation: 10,
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  void signin(BuildContext context) async {
    final email = _emailMobController.text;
    final password = _PasswordController.text;
    try {
      // ignore: unused_local_variable
      firebase_auth.UserCredential usercredentials = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SAVE_KEY, true);
      _emailMobController.clear();
      _PasswordController.clear();
    } catch (e) {
      String errorMessage = 'An error occurred';
      if (e is firebase_auth.FirebaseAuthException) {
        errorMessage = e.message ?? 'An error occurred';
      }
      Navigator.pop(context);
      final snackbar = SnackBar(
        content: Text(errorMessage),
        elevation: 10,
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      _PasswordController.clear();
    }
  }
}
