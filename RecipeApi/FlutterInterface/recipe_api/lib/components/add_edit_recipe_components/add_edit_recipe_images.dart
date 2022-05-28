import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'add_edit_recipe_ingredients.dart';
import '../recipe.dart';

class AddEditRecipeImages extends StatefulWidget {
  final Recipe recipeMetadata;
  final String tag;
  const AddEditRecipeImages({Key? key, required this.recipeMetadata, required this.tag}) : super(key: key);

  @override
  State<AddEditRecipeImages> createState() => _AddEditRecipeImagesState();
}

class _AddEditRecipeImagesState extends State<AddEditRecipeImages> {
  File? image;
  late XFile imagePath;

  late String tag;
  late Recipe entryData;

  @override
  void initState() {
    tag = widget.tag;
    entryData = widget.recipeMetadata;
    super.initState();
  }

  Future pickImageGallery() async {
    try {
      imagePath = (await ImagePicker().pickImage(source: ImageSource.gallery))!;

      if (imagePath == null) return;

      final imageFile = File(imagePath.path);
      setState(() => image = imageFile);
    } on PlatformException {
      return;
    }
  }

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
      child: Column(children: [
        image != null
            ? Image.file(
                image!,
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              )
            : FlutterLogo(
                size: 160,
              ),
        TextButton(
          child: Text('Choose from Gallery'),
          onPressed: () => pickImageGallery(),
        ),
        nextButton(context),
      ]),
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
          addImageToRecipe();
          pushAddEditRecipePreview(context);
        },
        child: const Text('Next'));
  }

  void addImageToRecipe() {
    entryData.images.add(imagePath.path);
  }

  void pushAddEditRecipePreview(BuildContext context) {
    Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddEditRecipeIngredients(recipeMetadata: entryData, tag: tag)))
        .then((data) => setState(() => {}));
  }
}
