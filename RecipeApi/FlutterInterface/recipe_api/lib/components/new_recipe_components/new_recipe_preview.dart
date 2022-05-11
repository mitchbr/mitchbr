import 'package:flutter/material.dart';

import '../recipe.dart';

class NewRecipePreview extends StatefulWidget {
  final Recipe recipeMetadata;
  const NewRecipePreview({Key? key, required this.recipeMetadata}) : super(key: key);

  @override
  State<NewRecipePreview> createState() => _NewRecipePreviewState();
}

class _NewRecipePreviewState extends State<NewRecipePreview> {
  late Recipe entryData;

  @override
  void initState() {
    entryData = widget.recipeMetadata;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Recipe"),
      ),
      body: bodyContent(context),
      floatingActionButton: publishButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /*
   *
   * Main list content
   * 
   */
  Widget bodyContent(BuildContext context) {
    return ListView.builder(
      itemCount: entryData.ingredients.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return recipeMetaData();
        } else if (index == entryData.ingredients.length + 1) {
          return recipeDetails();
        } else {
          return ingredientTile(index - 1);
        }
      },
    );
  }

  /*
   *
   * List Tiles
   * 
   */
  Widget recipeMetaData() {
    return Column(
      children: [
        ListTile(
            title: Text(
          entryData.recipeName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )),
        const ListTile(
            title: Text(
          'Ingredients',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )),
      ],
    );
  }

  Widget recipeDetails() {
    return Column(children: [
      const ListTile(
          title: Text(
        'Details',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      )),
      ListTile(title: Text(entryData.instructions)),
      ListTile(title: Text('Author: ${entryData.author}')),
      ListTile(title: Text('Category: ${entryData.category}')),
      const ListTile(
          title: SizedBox(
        height: 20,
      ))
    ]);
  }

  Widget ingredientTile(int index) {
    return ListTile(
      title: Text('${entryData.ingredients[index]['ingredientName']} '
          '(${entryData.ingredients[index]['ingredientAmount']} '
          '${entryData.ingredients[index]['ingredientUnit']})'),
    );
  }

  /*
   *
   * Publish Recipe
   * 
   */
  Widget publishButton(BuildContext context) {
    return TextButton(
        onPressed: () async {
          // TODO: Publish data to API

          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        child: const Text('Publish'));
  }
}
