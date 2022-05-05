import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'recipe.dart';

Future<String> fetchRecipes() async {
  final res = await http.get(
    Uri.parse(
        'https://i4yiwtjkg7.execute-api.us-east-2.amazonaws.com/getRecipes'),
  );

  if (res.statusCode == 200) {
    return res.body;
  } else {
    throw Exception('Failed to load recipes');
  }
}

class RecipesView extends StatefulWidget {
  const RecipesView({Key? key}) : super(key: key);

  @override
  State<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends State<RecipesView> {
  late Future<String> recipes;

  @override
  void initState() {
    super.initState();
    recipes = fetchRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchRecipes(),
        initialData: "Loading data...",
        builder: (BuildContext context, AsyncSnapshot<String> text) {
          final dat = text.data;
          if (dat == null) {
            return const Text("bad data");
          } else {
            return Text(dat);
          }
        });
  }
}
