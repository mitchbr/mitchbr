import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'recipe.dart';

class EditRecipe extends StatefulWidget {
  final Recipe recipeData;
  const EditRecipe({Key? key, required this.recipeData}) : super(key: key);

  @override
  State<EditRecipe> createState() => _EditRecipeState();
}

class _EditRecipeState extends State<EditRecipe> {
  /*
   *
   * Variable Declaration
   * 
   */
  final formKey = GlobalKey<FormState>();
  final nameKey = GlobalKey<FormState>();
  final ingredientKey = GlobalKey<FormState>();
  final instructionsKey = GlobalKey<FormState>();
  final authorKey = GlobalKey<FormState>();
  final TextEditingController _recipeNameControl = TextEditingController();
  final TextEditingController _ingredientNameControl = TextEditingController();
  final TextEditingController _amountControl = TextEditingController();
  final TextEditingController _unitControl = TextEditingController();
  final TextEditingController _instructionsControl = TextEditingController();
  final TextEditingController _authorControl = TextEditingController();

  var savedRecipe = true;
  var savedInstructions = true;
  late Map<String, dynamic> currentIngredient = {};

  late List<String> _categories = [""];
  String _category = "";
  late Recipe entryData;

  @override
  void initState() {
    entryData = widget.recipeData;
    _recipeNameControl.text = entryData.recipeName;
    _instructionsControl.text = entryData.instructions;
    loadFromJson();
    super.initState();
  }

  /*
   *
   * Load category data
   * 
   */
  void loadFromJson() async {
    final String response = await rootBundle.loadString('assets/recipe_categories.json');
    final data = await json.decode(response);
    setState(() {
      _categories = data["categories"].cast<String>();
      _category = entryData.category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Recipe"),
      ),
      body: formContent(context),
    );
  }

  /*
   *
   * Form list content
   * 
   */
  Widget formContent(BuildContext context) {
    return Form(
        key: formKey,
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView.builder(
                itemCount: entryData.ingredients.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        showRecipe(),
                        const ListTile(
                            title: Text(
                          'Ingredients',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                      ],
                    );
                  } else if (index == entryData.ingredients.length + 1) {
                    return Column(children: [
                      newEntryBox(context),
                      const ListTile(
                          title: Text(
                        'Instructions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                      showInstructions(),
                      saveButton(context)
                    ]);
                  } else {
                    return ingredientTile(index - 1);
                  }
                })));
  }

  /*
   *
   * Recipe Name Widgets
   * 
   */
  Widget showRecipe() {
    if (savedRecipe) {
      return recipeTile();
    } else {
      return recipeTextField();
    }
  }

  Widget recipeTile() {
    return ListTile(
        title: Text(entryData.recipeName),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => setState(() {
            savedRecipe = false;
          }),
        ));
  }

  Widget recipeTextField() {
    return Form(
        key: nameKey,
        child: ListTile(
          title: TextFormField(
            autofocus: true,
            controller: _recipeNameControl,
            decoration: const InputDecoration(labelText: 'Recipe Name', border: OutlineInputBorder()),
            textCapitalization: TextCapitalization.words,
            onSaved: (value) {
              if (value != null) {
                entryData.recipeName = value;
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
          ),
          trailing: IconButton(
            onPressed: (() => saveRecipeName()),
            icon: const Icon(Icons.check),
          ),
        ));
  }

  void saveRecipeName() {
    var currState = nameKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();
        setState(() {
          savedRecipe = true;
        });
      }
    }
  }

  /*
   *
   * New ingredient forms
   * 
   */
  Widget newEntryBox(BuildContext context) {
    return Form(
        key: ingredientKey,
        child: ListTile(
          title: Row(
            children: <Widget>[
              Expanded(child: ingredientNameField()),
              Expanded(child: ingredientAmountField()),
              Expanded(child: ingredientUnitField()),
            ],
          ),
          trailing: IconButton(onPressed: (() => saveIngredient()), icon: const Icon(Icons.add)),
        ));
  }

  Widget ingredientNameField() {
    return TextFormField(
      controller: _ingredientNameControl,
      autofocus: true,
      decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
      textCapitalization: TextCapitalization.words,
      onSaved: (value) {
        if (value != null) {
          currentIngredient['ingredientName'] = value;
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

  Widget ingredientAmountField() {
    return TextFormField(
      controller: _amountControl,
      autofocus: true,
      decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
      textCapitalization: TextCapitalization.words,
      onSaved: (value) {
        if (value != null) {
          currentIngredient['ingredientAmount'] = value;
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

  Widget ingredientUnitField() {
    return TextFormField(
      controller: _unitControl,
      autofocus: true,
      decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
      textCapitalization: TextCapitalization.words,
      onSaved: (value) {
        if (value != null) {
          currentIngredient['ingredientUnit'] = value;
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

  void saveIngredient() {
    var currState = ingredientKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();

        setState(() {
          entryData.ingredients.add(currentIngredient);
          _ingredientNameControl.clear();
          _amountControl.clear();
          _unitControl.clear();
        });
      }
    }
  }

  /*
   *
   * Ingredient display tile
   * 
   */
  Widget ingredientTile(int index) {
    return ListTile(
      title: Text('${entryData.ingredients[index]['ingredientName']} '
          '(${entryData.ingredients[index]['ingredientAmount']} '
          '${entryData.ingredients[index]['ingredientUnit']})'),
      trailing: IconButton(onPressed: (() => removeIngredient(index)), icon: const Icon(Icons.close)),
    );
  }

  void removeIngredient(int index) {
    setState(() {
      entryData.ingredients.removeAt(index);
    });
  }

  /*
   *
   * Instructions Widgets
   * 
   */

  Widget showInstructions() {
    if (savedInstructions) {
      return instructionsTile();
    } else {
      return instructionsTextField();
    }
  }

  Widget instructionsTile() {
    return ListTile(
        title: Text(entryData.instructions),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => setState(() {
            savedInstructions = false;
          }),
        ));
  }

  Widget instructionsTextField() {
    return Form(
        key: instructionsKey,
        child: ListTile(
          title: TextFormField(
            autofocus: true,
            controller: _instructionsControl,
            decoration: const InputDecoration(labelText: 'Instructions', border: OutlineInputBorder()),
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onSaved: (value) {
              if (value != null) {
                entryData.instructions = value;
              }
            },
            validator: (value) {
              var val = value;
              if (val != null) {
                if (val.isEmpty) {
                  return 'Please enter instructions';
                } else {
                  return null;
                }
              }
            },
          ),
          trailing: IconButton(onPressed: (() => saveInstructions()), icon: const Icon(Icons.check)),
        ));
  }

  void saveInstructions() {
    var currState = instructionsKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();
        setState(() {
          savedInstructions = true;
        });
      }
    }
  }

  /*
   *
   * Save details
   * 
   */
  Widget saveButton(BuildContext context) {
    return TextButton(onPressed: () async {}, child: const Text('Save'));
  }
}
