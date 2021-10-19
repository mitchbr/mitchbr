import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'recipe_entry.dart';
import 'new_recipe.dart';

class RecipesView extends StatefulWidget {
  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  var bodyWidget;
  var recipes;
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
    List<Map> entries = await db.rawQuery('SELECT * FROM recipes');
    final entriesList = entries.map((record) {
      return RecipeEntry(
          recipe: record['recipe'], items: json.decode(record['items']));
    }).toList();
    // Return if the list is no longer in the widget tree
    if (!mounted) return;

    setState(() {
      recipes = entriesList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            body: showBodyWidget(),
            floatingActionButton: FloatingActionButton(
                onPressed: () => pushNewRecipe(context),
                child: Icon(Icons.add))));
  }

  Widget showBodyWidget() {
    loadEntries();
    if (recipes == null) {
      return circularIndicator(context);
    } else if (recipes.length == 0) {
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
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return CheckboxListTile(
              title: Text('${recipes[index].recipe}'),
              value: hideTile,
              onChanged: (bool? value) {});
        });
  }

  void pushNewRecipe(BuildContext context) {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => NewRecipe()))
        .then((data) => setState(() => {}));
  }
}
