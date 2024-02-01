
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:k_party/User.dart';
import 'package:k_party/sqlitedatabasehelper.dart';


class AddUserScreen extends StatefulWidget {

   AddUserScreen();

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  late SqliteDatabaseHelper database;

  @override
  void initState() {
    database = SqliteDatabaseHelper.instance;
  }

  void addUser() async {
    final String name = nameController.text;
    final int age = int.tryParse(ageController.text) ?? 0;
    await database.insertUser(User(name:name)).then((value) =>
        Navigator.pop(context, User(id:value,name:name)));
    // Insert into the 'users' table
    // await widget.database.insert(
    //   'users',
    //   {'name': name, 'age': age},
    //   conflictAlgorithm: ConflictAlgorithm.replace,
    // );

    // Clear text fields after insertion
    nameController.clear();
    ageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Member',
        style: TextStyle(color: Colors.purple),
      )),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16.0),
            // TextField(
            //   controller: ageController,
            //   keyboardType: TextInputType.number,
            //   decoration: InputDecoration(labelText: 'Age'),
            // ),
            // SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: addUser,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}