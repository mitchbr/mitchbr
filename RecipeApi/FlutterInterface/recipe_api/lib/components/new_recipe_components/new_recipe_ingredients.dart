import 'package:flutter/material.dart';

import '../recipe.dart';

class NewRecipeIngredients extends StatefulWidget {
  const NewRecipeIngredients({Key? key}) : super(key: key);

  @override
  State<NewRecipeIngredients> createState() => _NewRecipeIngredientsState();
}

class _NewRecipeIngredientsState extends State<NewRecipeIngredients> {
  final formKey = GlobalKey<FormState>();
  List<Map> formIngredients = [];
  late Map<String, dynamic> currentIngredient = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  var entryData = Recipe(
    recipeId: 0,
    recipeName: '',
    instructions: '',
    author: '',
    publishDate: DateTime.now(),
    category: '',
    ingredients: [],
    images: [],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Recipe"),
      ),
      body: formContent(context),
      floatingActionButton: nextButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget formContent(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
            itemCount: formIngredients.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const ListTile(
                    title: Text(
                  'Ingredients',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ));
              } else if (index == formIngredients.length + 1) {
                return newEntryBox();
              } else {
                return ingredientTile(index - 1);
              }
            }));
  }

  Widget newEntryBox() {
    return Form(
        key: formKey,
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
      controller: _nameController,
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
      controller: _amountController,
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
      controller: _unitController,
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
    var currState = formKey.currentState;
    if (currState != null) {
      if (currState.validate()) {
        currState.save();

        setState(() {
          formIngredients.add(currentIngredient);
          _nameController.clear();
          _amountController.clear();
          _unitController.clear();
        });
      }
    }
  }

  Widget ingredientTile(int index) {
    return ListTile(
      title: Text('${formIngredients[index]['ingredientName']} '
          '(${formIngredients[index]['ingredientAmount']} '
          '${formIngredients[index]['ingredientUnit']})'),
      trailing: IconButton(onPressed: (() => removeIngredient(index)), icon: const Icon(Icons.close)),
    );
  }

  void removeIngredient(int index) {
    setState(() {
      formIngredients.removeAt(index);
    });
  }

  Widget nextButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          // TODO: parse data to new_recipe_preview

          pushNewRecipePreview(context);
        },
        child: const Text('Next'));
  }

  void pushNewRecipePreview(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const NewRecipeIngredients()))
        .then((data) => setState(() => {}));
  }
}
