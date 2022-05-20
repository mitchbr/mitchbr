import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../recipe.dart';
import 'package:recipe_api/components/new_recipe_components/new_recipe_ingredients.dart';

class NewRecipeMetadata extends StatefulWidget {
  const NewRecipeMetadata({Key? key}) : super(key: key);

  @override
  State<NewRecipeMetadata> createState() => _NewRecipeMetadataState();
}

class _NewRecipeMetadataState extends State<NewRecipeMetadata> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();

  late List<String> _categories = [""];
  String _category = "";

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
  void initState() {
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
      _category = data["categories"][0];
      entryData.category = _category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Recipe"),
      ),
      body: formContent(context),
    );
  }

  /*
   *
   * Metadata Form layout
   * 
   */
  Widget formContent(BuildContext context) {
    return Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: entryFieldLayout(),
        ));
  }

  Widget entryFieldLayout() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Title',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
        recipeNameTextField(),
        const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
        categoryDropdownField(),
        const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Instructions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
        instructionsTextField(),
        const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Author',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
        // TODO: Set author automatically
        authorTextField(),
        const SizedBox(height: 10),
        nextButton(context),
      ],
    ));
  }

  /*
   *
   * Form Fields
   * 
   */
  Widget recipeNameTextField() {
    return TextFormField(
      autofocus: true,
      controller: _nameController,
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
    );
  }

  Widget categoryDropdownField() {
    return DropdownButtonFormField<String>(
      items: _categories.map((String item) => DropdownMenuItem<String>(child: Text(item), value: item)).toList(),
      onChanged: (String? value) {
        setState(() {
          _category = value!;
          entryData.category = _category;
        });
      },
      value: _category,
    );
  }

  Widget instructionsTextField() {
    return TextFormField(
      autofocus: true,
      controller: _instructionsController,
      decoration: const InputDecoration(labelText: 'Instructions', border: OutlineInputBorder()),
      textCapitalization: TextCapitalization.words,
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
    );
  }

  Widget authorTextField() {
    return TextFormField(
      autofocus: true,
      controller: _authorController,
      decoration: const InputDecoration(labelText: 'Recipe Author', border: OutlineInputBorder()),
      textCapitalization: TextCapitalization.words,
      onSaved: (value) {
        if (value != null) {
          entryData.author = value;
        }
      },
      validator: (value) {
        var val = value;
        if (val != null) {
          if (val.isEmpty) {
            return 'Please enter an author';
          } else {
            return null;
          }
        }
      },
    );
  }

  /*
   *
   * Push next page
   * 
   */
  Widget nextButton(BuildContext context) {
    return TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(16.0),
          primary: Colors.white,
          textStyle: const TextStyle(fontSize: 20),
          backgroundColor: Colors.purple, // TODO: Make this auto-update with style
        ),
        onPressed: () async {
          var currState = formKey.currentState;
          if (currState != null) {
            if (currState.validate()) {
              currState.save();

              pushNewRecipeIngredients(context);
            }
          }
        },
        child: const Text('Next'));
  }

  void pushNewRecipeIngredients(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewRecipeIngredients(recipeMetadata: entryData)))
        .then((data) => setState(() => {}));
  }
}
