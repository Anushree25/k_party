import 'package:filter_list/filter_list.dart';
import 'package:flutter/material.dart';
import 'package:k_party/sqlitedatabasehelper.dart';
import 'package:k_party/mark_payment_screen.dart';

import 'User.dart';
import 'add_user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

final String _tableName = "users";

class MyApp extends StatelessWidget {
  MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<User> selectedUserList = [];
  List<User> randomUsers = [];
  List<User> userList = [];

  late SqliteDatabaseHelper database;

  @override
  void initState() {
       super.initState();
       initializeDatabase();

  }


  Future<void> initializeDatabase() async {
    database = SqliteDatabaseHelper.instance;
    List<User> updatedUserList = await database.getAllUsers();

    setState(() {
      userList = updatedUserList;
    });
  }
  void openFilterDialog() async {

    await FilterListDialog.display<User>(
      context,
      listData: userList,
      selectedListData: selectedUserList,
      choiceChipLabel: (user) => user!.name!,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (user, query) {
        return user.name!.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        setState(() {
          selectedUserList = List.from(list!);
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('K Party',
        style: TextStyle(color: Colors.purple),),
      ),
     floatingActionButton: Column(
       mainAxisAlignment: MainAxisAlignment.end,
       children: [
         FloatingActionButton(
           onPressed: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => CheckboxListScreen()),
             );
           },
           tooltip: 'Paid List',
           child: Icon(Icons.payment),
         ),
         SizedBox(height: 16),
         FloatingActionButton(
           onPressed: () {
             openFilterDialog();
           },
           tooltip: 'First Button',
           child: Icon(Icons.filter_list),
         ),
         SizedBox(height: 16), // Add some spacing between the buttons
         FloatingActionButton(
           onPressed: () async {
             final newUser  = await Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => AddUserScreen()),
             );
             updateUserData(newUser);
           },
           tooltip: 'Second Button',
           child: Icon(Icons.add),
         ),
       ],

     ),
      body:selectedUserList.isEmpty
          ? Center(child: Text('No user selected'))
          : Column(
        children: [
           Expanded(child:
           ListView.builder(
           itemCount: selectedUserList.length,
           itemBuilder: (context, index) {
            return UserCard(user: selectedUserList[index]);
           },
         )),
          SizedBox(height: 16),
          ElevatedButton(
          onPressed: chooseRandomUser,
          child: Text('Choose 1 lucky member'),
          style: ElevatedButton.styleFrom(
            // Add margin to the ElevatedButton
          padding: EdgeInsets.all( 8.0),
          ),
           ),
        ElevatedButton(
          onPressed: chooseRandomUsers,
          child: Text('Choose 2 lucky members'),
          style: ElevatedButton.styleFrom(
            // Add margin to the ElevatedButton
            padding: EdgeInsets.all( 8.0),
          ),

        ),

      Padding(
          padding: EdgeInsets.all( 16.0),
          child:Text(

        'Lucky Member(s): ${randomUsers.map((user) => user.name).join(', ')}',
      )),

  ]  ));
  }
  void updateUserData(User newUser) {
    // Update the user data on this screen
    setState(() {
      userList.add(newUser);
    });
  }

  void chooseRandomUsers() {
    final shuffledList = List.from(selectedUserList)..shuffle();
    randomUsers = shuffledList.take(2).whereType<User>().toList();
    setState(() {});
  }
  void chooseRandomUser() {
    final shuffledList = List.from(selectedUserList)..shuffle();
    randomUsers = shuffledList.take(1).whereType<User>().toList();
    setState(() {});
  }

}

class UserCard extends StatelessWidget {
  final User user;

  UserCard({required this.user});

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Column(
        children: [
          Text(
            user.name!,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          // Add more details or actions as needed
        ],
      ),
    );
  }
}





