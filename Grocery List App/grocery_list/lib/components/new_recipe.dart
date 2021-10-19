import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'recipe_entry.dart';

class NewRecipe extends StatefulWidget {
  @override
  _NewRecipeState createState() => _NewRecipeState();
}

class _NewRecipeState extends State<NewRecipe> {
  final formKey = GlobalKey<FormState>();
  var entryData = RecipeEntry(recipe: '', items: ['']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Add Recipe')), body: formContent(context));
  }

  Widget formContent(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(40),
        child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recipeTextField(),
                SizedBox(height: 20),
                Text('Add Recipe Items'),
                SizedBox(height: 20),
                ...addItems(),
                SizedBox(height: 20),
                saveButton(context),
              ],
            )));
  }

  Widget recipeTextField() {
    return TextFormField(
      autofocus: true,
      decoration:
          InputDecoration(labelText: 'Recipe', border: OutlineInputBorder()),
      onSaved: (value) {
        if (value != null) {
          entryData.recipe = value;
        }
      },
      validator: (value) {
        var val = value;
        if (val != null) {
          if (val.isEmpty) {
            return 'Please enter a recipe name';
          } else {
            return null;
          }
        }
      },
    );
  }

  List<Widget> addItems() {
    List<Widget> itemsTextFields = [];
    for (int i = 0; i < entryData.items.length; i++) {
      itemsTextFields.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(child: FriendTextFields(i)),
            SizedBox(
              width: 16,
            ),
            // we need add button at last friends row
            _addRemoveButton(i == entryData.items.length - 1, i),
          ],
        ),
      ));
    }
    return itemsTextFields;
  }

  Widget _addRemoveButton(bool add, int index) {
    return InkWell(
      onTap: () {
        if (add) {
          // add new text-fields at the top of all friends textfields
          entryData.items.insert(0, '');
        } else
          entryData.items.removeAt(index);
        setState(() {});
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: (add) ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          (add) ? Icons.add : Icons.remove,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget saveButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          var currState = formKey.currentState;
          if (currState != null) {
            if (currState.validate()) {
              currState.save();
              var sqlCreate = await rootBundle.loadString('assets/recipes.txt');
              var db = await openDatabase('recipes.db', version: 1,
                  onCreate: (Database db, int version) async {
                await db.execute(sqlCreate);
              });

              await db.transaction((txn) async {
                await txn.rawInsert(
                    'INSERT INTO recipes(recipe, items) VALUES(?, ?)', [
                  entryData.recipe,
                  entryData.items.toString(),
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

class FriendTextFields extends StatefulWidget {
  final int index;
  FriendTextFields(this.index);
  @override
  _FriendTextFieldsState createState() => _FriendTextFieldsState();
}

class _FriendTextFieldsState extends State<FriendTextFields> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      controller: _nameController,
      decoration: InputDecoration(hintText: 'Enter your friend\'s name'),
      validator: (v) {
        if (v!.trim().isEmpty) return 'Please enter something';

        return null;
      },
    );
  }
}
