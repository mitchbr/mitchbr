import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../main_screen.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Scaffold(
            appBar: AppBar(),
            body: Column(children: [
              TextButton(
                onPressed: clearChecklist,
                child: Text("Clear Checklist"),
              ),
              TextButton(
                onPressed: clearRecipes,
                child: Text("Clear Recipes"),
              ),
            ])));
  }

  void clearChecklist() async {
    var db = await openDatabase('groceries.db');
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM grocery_checklist;');
    });
  }

  void clearRecipes() async {
    var db = await openDatabase('recipes.db');
    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM recipes;');
    });
  }
}
