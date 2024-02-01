
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:k_party/sqlitedatabasehelper.dart';
import 'package:k_party/User.dart';

class CheckboxListScreen extends StatefulWidget {
  @override
  _CheckboxListScreenState createState() => _CheckboxListScreenState();
}

class _CheckboxListScreenState extends State<CheckboxListScreen> {
  List<User> _memberList = [];
  String _selectedPaymentOption = 'Online Payment';
  late SqliteDatabaseHelper database;
  final TextEditingController amountController = TextEditingController();

  Map<User, bool> _isCheckedList = {};
  String _result = '';

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    _memberList.forEach((item) {
      _isCheckedList[item] = false;
    });
    amountController.addListener(_updateResult);

  }

  Future<void> initializeDatabase() async {
    database = SqliteDatabaseHelper.instance;
    List<User> updatedUserList = await database.getAllUsers();

    setState(() {
      _memberList = updatedUserList;
    });
  }

  void _updateResult() {
    int textFieldValue = int.tryParse(amountController.text) ?? 0;
    int checkedCount = _isCheckedList.values.where((value) => value).length;
    setState(() {
      _result = (textFieldValue * checkedCount).toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paid List',
        style: TextStyle(color: Colors.purple),
      )),

      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedPaymentOption,
            onChanged: (String? newValue) {
              setState(() {
                _selectedPaymentOption = newValue!;
                _isCheckedList.clear();
              });
            },
            items: <String>['Online Payment', 'Cash']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          TextField(
            keyboardType: TextInputType.number,
            controller: amountController,
            decoration: InputDecoration(
              labelText: 'Enter Kitty Amount',contentPadding: EdgeInsets.all(8.0),
            ),
          ),
          Container(
              padding: EdgeInsets.all(10.0),
              child :Text('Total Amount: $_result',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold
                ),)
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _memberList.length,
              itemBuilder: (context, index) {
                User currentItem = _memberList[index];
                return ListTile(

                  onTap: (){
                    _showDeleteDialog(currentItem);
                  },
                  title: Text(currentItem.name),
                  trailing: Checkbox(
                    value: _isCheckedList[currentItem]??false,
                    onChanged: (bool? value) {
                      setState(() {
                        _isCheckedList[currentItem] = value!?? false;
                      });
                      _updateResult();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessageToWhatsApp,
        child: Icon(Icons.check),
      ),
    );
  }

  void _showDeleteDialog(User item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Item'),
          content: Text('Are you sure you want to delete $item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await database.deleteUser(item.id); // Remove item from database
                setState(() {
                  _memberList.remove(item); // Remove item from list
                });
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendMessageToWhatsApp() async {
    try {
      // Construct message with selected items
      String message = '$_selectedPaymentOption\n';
      _isCheckedList.forEach((item, isChecked) {
        if (isChecked) {
          message += '${item.name}\n';
        }
      });

      // Construct WhatsApp URL with the message
      String url = 'https://wa.me/?text=${Uri.encodeComponent(message)}';

      // Open WhatsApp with the message
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}
