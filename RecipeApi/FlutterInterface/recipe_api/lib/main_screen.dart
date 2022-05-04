import 'package:flutter/material.dart';

class Groceries extends StatefulWidget {
  const Groceries({Key? key}) : super(key: key);

  @override
  _GroceriesState createState() => _GroceriesState();
}

class _GroceriesState extends State<Groceries> {
  _GroceriesState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Recipes',
        theme: ThemeData(colorScheme: ColorScheme.dark()),
        home: DefaultTabController(
            length: 2,
            child: Builder(builder: (context) => groceriesScaffold(context))));
  }

  Widget groceriesScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe Api"),
      ),
      body: Text("Hi"),
    );
  }
}
