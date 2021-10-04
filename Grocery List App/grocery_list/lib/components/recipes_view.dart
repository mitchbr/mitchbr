import 'package:flutter/material.dart';

class RecipesView extends StatelessWidget {
  const RecipesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            body: Text('Recipes'),
            floatingActionButton: FloatingActionButton(
                onPressed: () => print('Adding a recipe'),
                child: Icon(Icons.add))));
  }
}
