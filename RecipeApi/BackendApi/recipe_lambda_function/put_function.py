import json

"""
    PUT endpoint
    Update a recipe's data
"""
def putRecipe(connection, event):
    recipe = json.loads(event["body"])
    
    cursor = connection.cursor()

    # Update recipe data
    cursor.execute(
        f'''UPDATE recipes_db.recipes
        SET recipeName = "{recipe["recipeName"]}", instructions = "{recipe["instructions"]}", author = "{recipe["author"]}", category = "{recipe["category"]}"
        WHERE recipeID = {recipe["recipeId"]}'''
    )
    connection.commit()

    # Update ingredient data
    # TODO: Make this happen without delete/post
    cursor.execute(
        f'DELETE FROM recipes_db.ingredients WHERE recipeID = {recipe["recipeId"]}'
    )
    connection.commit()

    ingredients = recipe["ingredients"]
    for ingredient in ingredients:
        cursor.execute(
            f'INSERT INTO recipes_db.ingredients(ingredientName, amount, unit, recipeID)'
            f'VALUES ("{ingredient["ingredientName"]}", "{ingredient["ingredientAmount"]}", "{ingredient["ingredientUnit"]}",'
            f'(SELECT recipeID FROM recipes_db.recipes WHERE recipeName = "{recipe["recipeName"]}" AND author = "{recipe["author"]}"))'
        )
        connection.commit()


    # Update image data
    # TODO: Make this happen without delete/post
    cursor.execute(
        f'DELETE FROM recipes_db.images WHERE recipeID = {recipe["recipeId"]}'
    )
    connection.commit()

    images = recipe["images"]
    for image in images:
        cursor.execute(
            f'INSERT INTO recipes_db.images(imageURL, recipeID)'
            f'VALUES ("{image}", (SELECT recipeID FROM recipes_db.recipes WHERE recipeName = "{recipe["recipeName"]}" AND author = "{recipe["author"]}"))'
        )
        connection.commit()
        
    return {
        'statusCode': 200,
        'message': 'Successfully updated recipe',
        'body': json.dumps(recipe)
    }
