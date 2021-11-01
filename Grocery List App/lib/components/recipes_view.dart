import 'package:flutter/material.dart';
import 'grocery_entry.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'new_recipe.dart';
import 'recipe_entry.dart';
import 'recipe_details.dart';

class RecipeEntries extends StatefulWidget {
  @override
  _RecipeEntriesState createState() => _RecipeEntriesState();
}

class _RecipeEntriesState extends State<RecipeEntries> {
  var bodyWidget;
  var checklistEntries;
  var sqlCreate;

  void loadSqlStartup() async {
    sqlCreate = await rootBundle.loadString('assets/recipes.txt');
  }

  void loadEntries() async {
    loadSqlStartup();
    var db = await openDatabase('recipes.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(sqlCreate);
    });
    List<Map> entries = await db.rawQuery('SELECT * FROM recipes_list');
    final entriesList = entries.map((record) {
      return RecipeEntry(
        recipe: record['recipe'],
        items: json.decode(record['items']),
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
      Icons.book,
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
            context, MaterialPageRoute(builder: (context) => NewRecipe()))
        .then((data) => setState(() => {}));
  }

  Widget groceryTile(int index) {
    return ListTile(
      title: Text('${checklistEntries[index].recipe}'),
      onTap: () => pushRecipeDetails(context, checklistEntries[index]),
    );
  }

  void pushRecipeDetails(BuildContext context, recipeEntry) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RecipeDetails(recipeEntry: recipeEntry)))
        .then((data) => setState(() => {}));
  }
}
