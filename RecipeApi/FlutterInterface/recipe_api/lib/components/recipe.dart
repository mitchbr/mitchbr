class Recipe {
  final int recipeId;
  final String recipeName;
  final String instructions;
  final String author;
  final DateTime publishDate;
  final String category;
  final List ingredients;
  final List images;

  const Recipe({
    required this.recipeId,
    required this.recipeName,
    required this.instructions,
    required this.author,
    required this.publishDate,
    required this.category,
    required this.ingredients,
    required this.images,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
        recipeId: json["RecipeId"],
        recipeName: json["RecipeName"],
        instructions: json["instructions"],
        author: json["author"],
        publishDate: json["publishDate"],
        category: json["category"],
        ingredients: [], //TODO: Implement
        images: []); //TODO: Implement
  }
}
