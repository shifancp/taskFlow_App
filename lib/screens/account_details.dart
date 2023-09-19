import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Acc_details extends StatefulWidget {
  const Acc_details({super.key});

  @override
  State<Acc_details> createState() => _Acc_detailsState();
}

class _Acc_detailsState extends State<Acc_details> {
  String? uploadedImageUrl;
  String? currentUserId;

  File _selectedImage = File('assets/images/avatar.png');
  int _selectedIndex = 1;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  // ignore: unused_field
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    )
  ];
  String? userGender;
  DateTime? userBirthDate;
  String? userEmail;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/account');
      }
    });
  }

  @override
  void initState() {
    createUserDocument();
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Stack(fit: StackFit.expand, children: [
          Image.asset(
            'assets/images/background_sign_up.jpeg',
            fit: BoxFit.cover,
          ),
          AppBar(
            backgroundColor: Colors.transparent,
            title: Align(
                alignment: Alignment.center, child: Text('Account Details')),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
      // floatingActionButton: FloatingActionButton(
      //   elevation: 20,
      //   onPressed: () {
      //     Navigator.pushNamed(context, '/addscreen');
      //   },
      //   child: Icon(Icons.add),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Container(
          child: Center(
              child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: getImage(),
                    radius: 100,
                  ),
                  Positioned(
                      bottom: 10,
                      right: 20,
                      child: IconButton(
                        onPressed: () {
                          _pickImage();
                        },
                        icon: Icon(
                          Icons.add_a_photo_rounded,
                          size: 50,
                        ),
                      )),
                ],
              ),
              Text(
                '$userEmail',
                style: TextStyle(color: Colors.teal, fontSize: 25),
              ),
              Text(
                  'Date of Birth: ${userBirthDate != null ? DateFormat.yMMMMd().format(userBirthDate!) : 'Not available'}'),
              Text(
                'Gender: ${userGender ?? 'Not available'}',
              ),
              ElevatedButton.icon(
                label: Text('Update'),
                onPressed: () async {
                  User? currentUserId = FirebaseAuth.instance.currentUser;
                  if (currentUserId != null) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .update({'profileImageUrl': uploadedImageUrl});
                    } catch (error) {
                      print("Error updating profile picture URL: $error");
                    }
                  }
                },
                icon: Icon(Icons.update),
              ),
              ElevatedButton.icon(
                  label: Text(
                    'Log Out',
                  ),
                  onPressed: () {
                    logOut(context);
                  },
                  icon: Icon(
                    Icons.logout,
                    size: 30,
                  ))
            ],
          )),
        ),
      ),
    );
  }

  Future<void> createUserDocument() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDocumentSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get();

        if (userDocumentSnapshot.exists) {
          setState(() {
            uploadedImageUrl = userDocumentSnapshot.data()?['profileImageUrl'];
            userEmail = currentUser.email ?? '';
            if (uploadedImageUrl != null) {
              _selectedImage = File(uploadedImageUrl!);
            }
          });
        } else {
          // User document doesn't exist, create it here
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .set({
            'profileImageUrl': uploadedImageUrl,
          });
        }
      } catch (e) {
        print("Error creating/updating user document: $e");
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDirImages = referenceRoot.child('Images');
      String uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference referenceImageToUpload = referenceDirImages.child(uniqueName);

      try {
        await referenceImageToUpload.putFile(File(image.path));
        uploadedImageUrl = await referenceImageToUpload.getDownloadURL();

        print("Image uploaded successfully. URL: $uploadedImageUrl");

        setState(() {
          _selectedImage = File(image.path);
        });
      } catch (e) {
        print("Error uploading image: $e");
      }
    } else {
      print("No image selected.");
    }
  }

  ImageProvider getImage() {
    if (uploadedImageUrl != null && uploadedImageUrl!.isNotEmpty) {
      return NetworkImage(uploadedImageUrl!); //image in firebasestore
      // ignore: unnecessary_null_comparison
    } else if (_selectedImage != null) {
      return FileImage(File(_selectedImage.path)); // Display selected image
    } else {
      return const AssetImage(
          "assets/blank-profile-picture-973460_640.webp"); //image to be shown default
    }
  }

  Future<void> getUserDetails() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDocumentSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .get();

        if (userDocumentSnapshot.exists) {
          setState(() {
            userGender = userDocumentSnapshot.data()?['gender'];
            Timestamp? birthDateTimestamp =
                userDocumentSnapshot.data()?['birthDate'];
            if (birthDateTimestamp != null) {
              userBirthDate = birthDateTimestamp.toDate();
            }
          });
        }
      } catch (e) {
        print("Error getting user details: $e");
      }
    }
  }

  Future<void> logOut(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/signup', (route) => false);
  }
}
