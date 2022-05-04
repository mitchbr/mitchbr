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
}
