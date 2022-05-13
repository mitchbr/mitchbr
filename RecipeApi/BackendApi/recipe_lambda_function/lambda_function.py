import json
# import boto3
import pymysql
from get_function import getRecipes
from post_function import postRecipe

"""
# Get secrets information
secrets_client = boto3.client('secretsmanager')
secret_arn = 'arn:aws:secretsmanager:us-east-2:369135786923:secret:RecipeDbAccess-qYKVSd'
auth_token = secrets_client.get_secret_value(SecretId=secret_arn).get('SecretString')
auth_json = json.loads(auth_token)

endpoint = auth_json["host"]
username = auth_json["username"]
password = auth_json["password"]
dbName = "recipes_db"
"""

# Local testing
with open("creds.json") as f:
    creds = json.load(f)

endpoint = creds["endpoint"]
username = creds["username"]
password = creds["pass"]
dbName = creds["db_name"]

# Connect to DB
connection = pymysql.connect(host=endpoint, user=username, passwd=password, db=dbName)

# Create the paths for the four requests
DEFAULT_RAW_PATH = "/"
GET_RAW_PATH = "/getRecipes"
CREATE_RAW_PATH = "/createRecipe"
PUT_RAW_PATH = "/updateRecipe"
DELETE_RAW_PATH = "/deleteRecipe"


"""
    Main API entrypoint
"""
def lambda_handler(event, context):
    if event["rawPath"] == DEFAULT_RAW_PATH:
        return {
            'statusCode': 200,
            'body': json.dumps('got data!')
        }
    elif event["rawPath"] == GET_RAW_PATH:
        return getRecipes(connection)
    elif event["rawPath"] == CREATE_RAW_PATH:
        return postRecipe(connection, event)
    elif event["rawPath"] == PUT_RAW_PATH:
        return putRecipe(event)
    elif event["rawPath"] == DELETE_RAW_PATH:
        return delRecipe(event)
    else:
        return {
            'statuscode': 404,
            'body': json.dumps('Please enter a proper endpoint')
        }


"""
    PUT endpoint
    Update a recipe's data
"""
def putRecipe(event):
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
            f'VALUES ("{ingredient["ingredientName"]}", "{ingredient["ingredientAmount"]}", "{ingredient["ingredientUnit"]}", (SELECT recipeID FROM recipes_db.recipes WHERE recipeName = "{recipe["recipeName"]}"))'
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
            f'VALUES ("{image}", (SELECT recipeID FROM recipes_db.recipes WHERE recipeName = "{recipe["recipeName"]}"))'
        )
        connection.commit()
        
    return {
        'statuscode': 200,
        'message': json.dumps('Successfully added to database'),
        'body': json.dumps(recipe)
    }


"""
    DELETE endpoint
    Remove a recipe
"""
def delRecipe(event):
    recipe = json.loads(event["body"])
    
    cursor = connection.cursor()
    
    # Get the recipe name to let the user know what's been deleted
    cursor.execute(
        f'''SELECT recipeName
        FROM recipes_db.recipes
        WHERE recipeID = {recipe["recipeId"]}'''
    )
    deletedName = cursor.fetchall()

    # Delete ingredient data
    cursor.execute(
        f'DELETE FROM recipes_db.ingredients WHERE recipeID = {recipe["recipeId"]}'
    )
    connection.commit()

    # Delete image data
    cursor.execute(
        f'DELETE FROM recipes_db.images WHERE recipeID = {recipe["recipeId"]}'
    )
    connection.commit()

    # Delete recipe data
    cursor.execute(
        f'DELETE FROM recipes_db.recipes WHERE recipeID = {recipe["recipeId"]}'
    )
    connection.commit()
    
    return {
        'statuscode': 200,
        'message': json.dumps(f'Successfully deleted {deletedName[0]} from the database'),
    }