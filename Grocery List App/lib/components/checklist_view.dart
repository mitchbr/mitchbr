import 'package:flutter/material.dart';
import 'grocery_entry.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import 'new_grocery.dart';

class ChecklistEntries extends StatefulWidget {
  @override
  _ChecklistEntriesState createState() => _ChecklistEntriesState();
}

class _ChecklistEntriesState extends State<ChecklistEntries> {
  var bodyWidget;
  var checklistEntries;
  var sqlCreate;

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
        floatingActionButton: FloatingActionButton(
            onPressed: () => pushNewEntry(context), child: Icon(Icons.add)));
  }

  Widget bodyBuilder(BuildContext context) {
    loadEntries();
    if (checklistEntries == null) {
      return circularIndicator(context);
    } else if (checklistEntries.length == 0) {
      return emptyWidget(context);
    } else {
      return entriesList(context);
    }
  }

  Widget emptyWidget(BuildContext context) {
    return Center(
        child: Icon(
      Icons.check,
      size: 100,
    ));
  }

  Widget circularIndicator(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }

  Widget entriesList(BuildContext context) {
    return ListView.builder(
        itemCount: checklistEntries.length,
        itemBuilder: (context, index) {
          return groceryTile(index);
        });
  }

  void pushNewEntry(BuildContext context) {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewGroceryItem()))
        .then((data) => setState(() => {}));
  }

  Widget groceryTile(int index) {
    return ListTile(
        title: Text('${checklistEntries[index].item}'),
        leading: IconButton(
            onPressed: () => delete(checklistEntries[index].item),
            icon: Icon(Icons.check)));
  }

  void delete(String title) async {
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
}
