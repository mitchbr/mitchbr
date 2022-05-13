import json

"""
    POST endpoint
    Add a new recipe
"""
def postRecipe(connection, event):
    newRecipe = json.loads(event["body"])
    
    cursor = connection.cursor()

    # Verify this author hasn't already posted a recipe with this name
    # TODO: implement

    # Post the recipe data first
    cursor.execute(
        f'INSERT INTO recipes_db.recipes(recipeName, instructions, author, publishDate, category)'
        f'VALUES ("{newRecipe["recipeName"]}", "{newRecipe["instructions"]}", "{newRecipe["author"]}", CURDATE(), "{newRecipe["category"]}")'
    )
    connection.commit()

    # Post ingredient data next
    ingredients = newRecipe["ingredients"]
    for ingredient in ingredients:
        cursor.execute(
            f'INSERT INTO recipes_db.ingredients(ingredientName, amount, unit, recipeID)'
            f'VALUES ("{ingredient["ingredientName"]}", "{ingredient["ingredientAmount"]}", "{ingredient["ingredientUnit"]}",'
            f'(SELECT recipeID FROM recipes_db.recipes WHERE recipeName = "{newRecipe["recipeName"]}" AND author = "{newRecipe["author"]}"))'
        )
        connection.commit()
    
    # Post image data
    images = newRecipe["images"]
    for image in images:
        cursor.execute(
            f'INSERT INTO recipes_db.images(imageURL, recipeID)'
            f'VALUES ("{image}", (SELECT recipeID FROM recipes_db.recipes WHERE recipeName = "{newRecipe["recipeName"]}" AND author = "{newRecipe["author"]}"))'
        )
        connection.commit()
        
    return {
        'statusCode': 200,
        'message': 'Successfully added to database',
        'body': json.dumps(newRecipe)
    }
