import 'package:flutter/material.dart';

class ChecklistView extends StatefulWidget {
  @override
  _ChecklistViewState createState() => _ChecklistViewState();
}

class _ChecklistViewState extends State<ChecklistView> {
  late int _itemCount;
  late List<Map<String, dynamic>> _values;

  @override
  void initState() {
    super.initState();
    _itemCount = 0;
    _values = [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            body: Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Flexible(
                        child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _itemCount,
                      itemBuilder: (context, index) {
                        return checkListItem(index);
                      },
                    )),
                    SizedBox(height: 20.0),
                    TextButton(
                        onPressed: () async {
                          setState(() {
                            _itemCount++;
                          });
                        },
                        child: Row(children: [
                          Icon(Icons.add),
                          Text(
                            'Add Item',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ])),
                  ],
                ))));
  }

  _onReorder(oldIndex, newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex = newIndex - 1;
      }
      final element = _values.removeAt(oldIndex);
      _values.insert(newIndex, element);
    });
  }

  Widget checkListItem(int key) {
    return Row(
      key: ValueKey(key),
      children: [
        Text('$key'),
        SizedBox(width: 20.0),
        Expanded(child: TextFormField(
          onChanged: (val) {
            _onUpdate(key, val);
          },
        )),
        SizedBox(width: 5.0),
        IconButton(
            icon: Icon(
              Icons.close,
            ),
            onPressed: () {
              setState(() {
                _values.removeAt(key);
                _itemCount--;
              });
            }),
      ],
    );
  }

  _onUpdate(int key, String val) {
    _removeRow(key);

    Map<String, dynamic> json = {'id': key, 'value': val};
    _values.add(json);
    print('$_values');
  }

  _removeRow(int key) {
    int foundKey = -1;
    for (var map in _values) {
      if (map.containsKey('id')) {
        if (map['id'] == key) {
          foundKey = key;
          break;
        }
      }
    }

    if (foundKey != -1) {
      _values.removeWhere((map) {
        return map['id'] == foundKey;
      });
    }
  }
}
