import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import 'recipe_entry.dart';

class RecipeDetails extends StatefulWidget {
  final RecipeEntry recipeEntry;
  const RecipeDetails({Key? key, required this.recipeEntry}) : super(key: key);

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState(recipeEntry);
}

class _RecipeDetailsState extends State<RecipeDetails> {
  final RecipeEntry recipeEntry;
  _RecipeDetailsState(this.recipeEntry);

  late List<bool> checkedValues;

  @override
  void initState() {
    super.initState();
    checkedValues =
        List.filled(recipeEntry.items.length, true, growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipeEntry.recipe),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.delete_rounded),
              onPressed: () {
                deleteRecipe(recipeEntry.recipe);
              },
            ),
          ),
        ],
      ),
      body: entriesList(context),
      floatingActionButton: addToGroceryList(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget entriesList(BuildContext context) {
    return ListView.builder(
        itemCount: recipeEntry.items.length,
        itemBuilder: (context, index) {
          return itemTile(index);
        });
  }

  Widget itemTile(int index) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return CheckboxListTile(
        title: Text(recipeEntry.items[index]),
        value: checkedValues[index],
        onChanged: (newValue) {
          setState(() {
            checkedValues[index] = newValue!;
          });
        },
        activeColor: Colors.teal,
        controlAffinity: ListTileControlAffinity.leading,
      );
    });
  }

  Widget addToGroceryList(BuildContext context) {
    return TextButton(
      child: const Text('Save to Grocery List'),
      onPressed: () async {
        var sqlCreate = await rootBundle.loadString('assets/grocery.txt');
        var db = await openDatabase('grocery.db', version: 1,
            onCreate: (Database db, int version) async {
          await db.execute(sqlCreate);
        });

        for (int i = 0; i < recipeEntry.items.length; i++) {
          if (checkedValues[i]) {
            await db.transaction((txn) async {
              await txn.rawInsert(
                  'INSERT INTO grocery_checklist(item) VALUES(?)',
                  [recipeEntry.items[i]]);
            });
          }
        }
        await db.close();

        Navigator.of(context).pop();
      },
    );
  }

  void deleteRecipe(String title) async {
    var sqlCreate = await rootBundle.loadString('assets/recipes.txt');
    var db = await openDatabase('recipes.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(sqlCreate);
    });

    await db.transaction((txn) async {
      await txn.rawDelete('DELETE FROM recipes_list WHERE recipe = ?', [title]);
    });

    setState(() {
      Navigator.of(context).pop();
    });
  }
}
