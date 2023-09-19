import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Add_Screen extends StatefulWidget {
  Add_Screen({super.key});

  @override
  State<Add_Screen> createState() => _Add_ScreenState();
}

class _Add_ScreenState extends State<Add_Screen> {
  final CollectionReference todo =
      FirebaseFirestore.instance.collection('todo');
  final _titleEditingController = TextEditingController();
  final _descEditingController = TextEditingController();
  var _dateEditingController = TextEditingController();

  final _timeController = TextEditingController();

  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();
  String? priority;
  bool _isPressedImportant = false;
  bool _isPressedPlanned = false;
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
                Text(
                  'Create',
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.search_outlined,
                    size: 30,
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          // height: 1200.0,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                controller: _titleEditingController,
                decoration: InputDecoration(
                  labelText: 'What To Do?',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                maxLines: null,
                controller: _descEditingController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsetsDirectional.only(
                      top: 0, bottom: 100, start: 10),
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        priority = 'important';
                        setState(() {
                          _isPressedImportant = true;
                          _isPressedPlanned = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPressedImportant
                            ? Colors.teal.shade300
                            : Colors.teal,
                        elevation: _isPressedImportant ? 0 : 8,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/star.png',
                            height: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Important'),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
                            height: 10,
                            width: 10,
                          ),
                        ],
                      )),
                  SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        priority = 'planned';
                        setState(() {
                          _isPressedPlanned = true;
                          _isPressedImportant = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPressedPlanned
                            ? Colors.teal.shade300
                            : Colors.teal,
                        elevation: _isPressedPlanned ? 0 : 8,
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/planning.png',
                            height: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Planned'),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.orange),
                          ),
                        ],
                      ))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: _dateEditingController,
                      decoration: InputDecoration(
                        labelText: 'Enter the Date(yyyy-mm-dd)',
                        border: OutlineInputBorder(),
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
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.datetime,
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Enter Time',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _selectTime(context);
                      },
                      icon: Icon(
                        Icons.timelapse,
                        size: 30,
                      ))
                ],
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    addItem();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.done),
                  label: Text('Done'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Set initial date to current date
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _dateEditingController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);

    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
        _timeController.text = "${selectedTime.format(context)}";
      });
  }

  void addItem() async {
    final currentUserId = FirebaseAuth.instance.currentUser;
    if (currentUserId != null) {
      final todoItems = {
        'title': _titleEditingController.text,
        'description': _descEditingController.text,
        'priority': priority,
        'date': _dateEditingController.text,
        'time': _timeController.text
      };
      final todoRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId.uid)
          .collection('tasks');
      // ignore: unused_local_variable
      final newTodoRef = await todoRef.add(todoItems);
      setState(() {});
      // todo.add(todoItems);
    }
  }
}
