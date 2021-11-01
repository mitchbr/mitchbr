import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import 'grocery_entry.dart';

class NewGroceryItem extends StatefulWidget {
  const NewGroceryItem({Key? key}) : super(key: key);

  @override
  _NewGroceryItemState createState() => _NewGroceryItemState();
}

class _NewGroceryItemState extends State<NewGroceryItem> {
  _NewGroceryItemState();

  final formKey = GlobalKey<FormState>();
  var entryData = GroceryEntry(item: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Grocery List Item"),
        ),
        body: formContent(context));
  }

  Widget formContent(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(40),
        child: Form(
            key: formKey,
            child: Column(
              children: [
                itemTextField(),
                SizedBox(height: 10),
                saveButton(context)
              ],
            )));
  }

  Widget itemTextField() {
    return TextFormField(
      autofocus: true,
      decoration:
          InputDecoration(labelText: 'Item', border: OutlineInputBorder()),
      onSaved: (value) {
        if (value != null) {
          entryData.item = value;
        }
      },
      validator: (value) {
        var val = value;
        if (val != null) {
          if (val.isEmpty) {
            return 'Please enter a value';
          } else {
            return null;
          }
        }
      },
    );
  }

  Widget saveButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          var currState = formKey.currentState;
          if (currState != null) {
            if (currState.validate()) {
              currState.save();
              var sqlCreate = await rootBundle.loadString('assets/grocery.txt');
              var db = await openDatabase('grocery.db', version: 1,
                  onCreate: (Database db, int version) async {
                await db.execute(sqlCreate);
              });

              await db.transaction((txn) async {
                await txn.rawInsert(
                    'INSERT INTO grocery_checklist(item) VALUES(?)',
                    [entryData.item]);
              });

              await db.close();

              Navigator.of(context).pop();
            }
          }
        },
        child: Text("Save"));
  }
}
