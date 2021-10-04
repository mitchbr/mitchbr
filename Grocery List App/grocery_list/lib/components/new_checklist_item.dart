import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'grocery_entry.dart';

class AddChecklistItem extends StatefulWidget {
  const AddChecklistItem({Key? key}) : super(key: key);

  @override
  _AddChecklistItemState createState() => _AddChecklistItemState();
}

class _AddChecklistItemState extends State<AddChecklistItem> {
  final formKey = GlobalKey<FormState>();
  var entryData = GroceryEntry(item: '', amount: '', show: 'True');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Checklist Item')),
      body: formContent(context),
    );
  }

  Widget formContent(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(40),
        child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                itemTextField(),
                Padding(padding: const EdgeInsets.all(10)),
                amountTextField(),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [cancelButton(context), saveButton(context)],
                )
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
            return 'Please enter an item name';
          } else {
            return null;
          }
        }
      },
    );
  }

  Widget amountTextField() {
    return TextFormField(
      autofocus: true,
      decoration:
          InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
      onSaved: (value) {
        if (value != null) {
          entryData.amount = value;
        }
      },
      validator: (value) {
        var val = value;
        if (val != null) {
          if (val.isEmpty) {
            return 'Please enter an amount';
          } else {
            return null;
          }
        }
      },
    );
  }

  Widget cancelButton(BuildContext context) {
    return TextButton(
        onPressed: () => Navigator.pop(context), child: Text('Cancel'));
  }

  Widget saveButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          var currState = formKey.currentState;
          if (currState != null) {
            if (currState.validate()) {
              currState.save();
              var sqlCreate =
                  await rootBundle.loadString('assets/groceries.txt');
              var db = await openDatabase('groceries.db', version: 1,
                  onCreate: (Database db, int version) async {
                await db.execute(sqlCreate);
              });

              await db.transaction((txn) async {
                await txn.rawInsert(
                    'INSERT INTO grocery_checklist(item, amount, show) VALUES(?, ?, ?)',
                    [
                      entryData.item,
                      entryData.amount,
                      entryData.show,
                    ]);
              });

              await db.close();

              Navigator.of(context).pop();
            }
          }
        },
        child: Text('Save'));
  }
}
