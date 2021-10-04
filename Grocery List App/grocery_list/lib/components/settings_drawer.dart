import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../main_screen.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(child: Scaffold(appBar: AppBar(), body: Text("TEXT")));
  }
}
