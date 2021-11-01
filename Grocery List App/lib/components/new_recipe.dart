import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

import 'recipe_entry.dart';

class NewRecipe extends StatefulWidget {
  const NewRecipe({Key? key}) : super(key: key);

  @override
  _NewRecipeState createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  final formKey = GlobalKey<FormState>();
  var entryData = RecipeEntry(recipe: '', items: [null]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Recipe"),
      ),
      body: formContent(context),
      floatingActionButton: saveButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget formContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            recipeTextField(),
            const Padding(padding: EdgeInsets.all(10)),
            Text('Recipe Items'),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: entryData.items.length,
                itemBuilder: (context, index) {
                  return itemsTile(index);
                },
              ),
            ),
            TextButton(
              child: Row(children: [
                Icon(Icons.add),
                Text('Add Item'),
              ]),
              onPressed: () {
                entryData.items.add(null);
                setState(() {});
              },
            ),
            //saveButton(context)
          ],
        ),
      ),
    );
  }

  Widget recipeTextField() {
    return TextFormField(
      autofocus: true,
      decoration: const InputDecoration(
          labelText: 'Recipe Name', border: OutlineInputBorder()),
      onSaved: (value) {
        if (value != null) {
          entryData.recipe = value;
        }
      },
      validator: (value) {
        var val = value;
        if (val != null) {
          if (val.isEmpty) {
            return 'Please enter a recipe title';
          } else {
            return null;
          }
        }
      },
    );
  }

  Widget itemsTile(int index) {
    return ListTile(
      title: TextFormField(
        onChanged: (val) {
          onUpdate(index, val);
        },
        autofocus: true,
        decoration: const InputDecoration(
            labelText: 'Item', border: OutlineInputBorder()),
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
      ),
      trailing: IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          entryData.items.removeAt(index);
          setState(() {});
        },
      ),
    );
  }

  void onUpdate(int index, String val) {
    // Check if item exists
    entryData.items.removeAt(index);
    entryData.items.insert(index, val);
    setState(() {});
  }

  Widget saveButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          var currState = formKey.currentState;
          if (currState != null) {
            if (currState.validate()) {
              currState.save();
              var sqlCreate = await rootBundle.loadString('assets/recipes.txt');
              var db = await openDatabase(
                'recipes.db',
                version: 1,
                onCreate: (Database db, int version) async {
                  await db.execute(sqlCreate);
                },
              );

              await db.transaction(
                (txn) async {
                  await txn.rawInsert(
                      'INSERT INTO recipes_list(recipe, items) VALUES(?, ?)',
                      [entryData.recipe, json.encode(entryData.items)]);
                },
              );

              await db.close();

              Navigator.of(context).pop();
            }
          }
        },
        child: const Text("Save"));
  }
}
