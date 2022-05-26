import 'package:flutter/material.dart';

import 'add_edit_recipe_ingredients.dart';

class AddEditRecipeImages extends StatefulWidget {
  const AddEditRecipeImages({Key? key}) : super(key: key);

  @override
  State<AddEditRecipeImages> createState() => _AddEditRecipeImagesState();
}

class _AddEditRecipeImagesState extends State<AddEditRecipeImages> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" Recipe"),
      ),
      body: formContent(context),
    );
  }

  Widget formContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
    );
  }
}
