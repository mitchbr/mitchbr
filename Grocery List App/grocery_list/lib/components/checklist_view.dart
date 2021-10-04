import 'package:flutter/material.dart';
import 'package:grocery_list/components/grocery_entry.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'new_checklist_item.dart';

class ChecklistView extends StatefulWidget {
  const ChecklistView({Key? key}) : super(key: key);

  @override
  State<ChecklistView> createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  var bodyWidget;
  var groceryChecklist;
  var sqlCreate;

  void loadSqlStartup() async {
    sqlCreate = await rootBundle.loadString('assets/groceries.txt');
  }

  void loadEntries() async {
    loadSqlStartup();
    var db = await openDatabase('groceries.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(sqlCreate);
    });
    List<Map> entries = await db.rawQuery('SELECT * FROM grocery_checklist');
    final entriesList = entries.map((record) {
      return GroceryEntry(
          item: record['item'], amount: record['amount'], show: record['show']);
    }).toList();
    setState(() {
      groceryChecklist = entriesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    loadEntries();
    return Container(
        child: Scaffold(
            body: showBodyWidget(),
            floatingActionButton: FloatingActionButton(
                onPressed: () => pushNewChecklistItem(context),
                child: Icon(Icons.add))));
  }

  Widget showBodyWidget() {
    if (groceryChecklist == null) {
      return circularIndicator(context);
    } else if (groceryChecklist.length == 0) {
      return emptyWidget(context);
    } else {
      return entriesList(context);
    }
  }

  Widget emptyWidget(BuildContext context) {
    return Center(
        child: Icon(
      Icons.book,
      size: 100,
    ));
  }

  Widget circularIndicator(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }

  Widget entriesList(BuildContext context) {
    // TODO: Get checkboxes working
    bool? hideTile = false;
    return ListView.builder(
        itemCount: groceryChecklist.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
              title: Text('${groceryChecklist[index].item}'),
              value: hideTile,
              onChanged: (bool? value) => setState(() {
                    hideTile = value;
                  }));
        });
  }

  void pushNewChecklistItem(BuildContext context) {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddChecklistItem()))
        .then((data) => setState(() => {}));
  }
}
