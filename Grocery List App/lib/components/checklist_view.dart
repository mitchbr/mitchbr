import 'package:flutter/material.dart';
import 'grocery_entry.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class ChecklistEntries extends StatefulWidget {
  @override
  _ChecklistEntriesState createState() => _ChecklistEntriesState();
}

class _ChecklistEntriesState extends State<ChecklistEntries> {
  var bodyWidget;
  var checklistEntries;
  var sqlCreate;
  var prevDeleted = null;

  final formKey = GlobalKey<FormState>();
  var entryData = GroceryEntry(item: '');
  final TextEditingController _entryController = new TextEditingController();

  void loadSqlStartup() async {
    sqlCreate = await rootBundle.loadString('assets/grocery.txt');
  }

  void loadEntries() async {
    loadSqlStartup();
    var db = await openDatabase('grocery.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(sqlCreate);
    });
    List<Map> entries = await db.rawQuery('SELECT * FROM grocery_checklist');
    final entriesList = entries.map((record) {
      return GroceryEntry(
        item: record['item'],
      );
    }).toList();
    if (mounted) {
      setState(() {
        checklistEntries = entriesList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: bodyBuilder(context),
      floatingActionButton: undoButton(),
    );
  }

  Widget bodyBuilder(BuildContext context) {
    loadEntries();
    if (checklistEntries == null) {
      return circularIndicator(context);
    } else {
      return entriesList(context);
    }
  }

  Widget circularIndicator(BuildContext context) {
    return const Center(child: const CircularProgressIndicator());
  }

  Widget entriesList(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
            itemCount: checklistEntries.length + 1,
            itemBuilder: (context, index) {
              if (index == checklistEntries.length) {
                return newEntryBox(context);
              } else {
                return groceryTile(index);
              }
            }));
  }

  Widget groceryTile(int index) {
    return ListTile(
        title: Text('${checklistEntries[index].item}'),
        leading: IconButton(
            onPressed: () => delete(checklistEntries[index].item),
            icon: const Icon(Icons.check)));
  }

  void delete(String title) async {
    prevDeleted = title;
    loadSqlStartup();
    var db = await openDatabase('grocery.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(sqlCreate);
    });

    await db.transaction((txn) async {
      await txn
          .rawDelete('DELETE FROM grocery_checklist WHERE item = ?', [title]);
    });

    setState(() {});
  }

  Widget newEntryBox(BuildContext context) {
    return Form(
        key: formKey,
        child: ListTile(
          title: itemTextField(),
          trailing: IconButton(
              onPressed: (() => saveEntryItem()), icon: const Icon(Icons.add)),
        ));
  }

  Widget itemTextField() {
    return TextFormField(
      controller: _entryController,
      autofocus: true,
      decoration: const InputDecoration(
          labelText: 'New Item', border: const OutlineInputBorder()),
      textCapitalization: TextCapitalization.words,
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

  void saveEntryItem() async {
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
          await txn.rawInsert('INSERT INTO grocery_checklist(item) VALUES(?)',
              [entryData.item]);
        });

        await db.close();

        setState(() {
          _entryController.clear();
        });
      }
    }
  }

  Widget undoButton() {
    return Visibility(
        visible: (prevDeleted != null),
        child: ElevatedButton.icon(
            onPressed: (() => insertUndo()),
            icon: const Icon(Icons.undo),
            label: const Text('Undo')));
  }

  void insertUndo() async {
    var sqlCreate = await rootBundle.loadString('assets/grocery.txt');
    var db = await openDatabase('grocery.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(sqlCreate);
    });

    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO grocery_checklist(item) VALUES(?)', [prevDeleted]);
    });

    await db.close();

    setState(() {
      prevDeleted = null;
    });
  }
}
