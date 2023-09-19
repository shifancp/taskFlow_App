import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home_Screen extends StatefulWidget {
  Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  String? userProfilePictureUrl;
  late Stream<QuerySnapshot> _stream;
  final CollectionReference todo =
      FirebaseFirestore.instance.collection('todo');
  int _selectedIndex = 0;
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
  @override
  void initState() {
    getUserDetails();
    _stream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('tasks')
        .snapshots();
    super.initState();
  }

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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TO DO LIST'),
                CircleAvatar(
                  backgroundImage: userProfilePictureUrl != null
                      ? NetworkImage(userProfilePictureUrl!)
                      : null, // Use null for no image
                  child: userProfilePictureUrl == null
                      ? Image.asset('assets/images/avatar.png')
                      : null,
                ),
              ],
            ),
          ),
        ]),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> todoList = snapshot.data.docs;
            final List<Color> itemColors = [
              Colors.blueGrey,
              Colors.blue,
              Colors.green,
              Colors.amberAccent
            ];
            return ListView.builder(
              itemCount:
                  (todoList.length / 2).ceil(), // Calculate number of rows
              itemBuilder: (context, rowIndex) {
                final int index1 = rowIndex * 2;
                final int index2 = index1 + 1;

                // Check if index2 is within the bounds of the list
                final bool hasSecondItem = index2 < todoList.length;

                return Row(
                  children: [
                    _buildTodoItem(todoList[index1],
                        itemColors[index1 % itemColors.length]),
                    if (hasSecondItem)
                      _buildTodoItem(todoList[index2],
                          itemColors[index2 % itemColors.length]),
                  ],
                );
              },
            );
          }
          return Container();
        },
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
      floatingActionButton: FloatingActionButton(
        elevation: 20,
        onPressed: () {
          Navigator.pushNamed(context, '/addscreen');
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTodoItem(DocumentSnapshot todoSnap, Color color) {
    String priority = todoSnap['priority'];
    Color containerColor =
        (priority == 'important') ? Colors.red : Colors.orange;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 5,
                    blurStyle: BlurStyle.normal,
                  ),
                ],
                borderRadius: BorderRadius.circular(10)),
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          todoSnap['title'],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: containerColor,
                        ),
                      ),
                    ],
                  ),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(todoSnap['description'])),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Text(todoSnap['date']),
                          SizedBox(
                            width: 10,
                          ),
                          Text(todoSnap['time'])
                        ],
                      )),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamed('/update', arguments: {
                                  'title': todoSnap['title'],
                                  'description': todoSnap['description'],
                                  'priority': todoSnap['priority'],
                                  'date': todoSnap['date'],
                                  'time': todoSnap['time'],
                                  'id': todoSnap.id,
                                });
                              },
                              icon: Icon(Icons.edit)),
                          IconButton(
                              onPressed: () {
                                deleteData(todoSnap.id);
                              },
                              icon: Icon(Icons.delete))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void deleteData(docId) async {
    final currentUserId = FirebaseAuth.instance.currentUser;
    if (currentUserId != null) {
      final todoRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId.uid)
          .collection('tasks');
      await todoRef.doc(docId).delete();
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
            userProfilePictureUrl =
                userDocumentSnapshot.data()?['profileImageUrl'];
          });
        }
      } catch (e) {
        print("Error getting user details: $e");
      }
    }
  }
}
