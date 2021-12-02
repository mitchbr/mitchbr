import uuid
import json
import boto3

# Create the paths for the four requests
GET_RAW_PATH = "/getRecipes"
CREATE_RAW_PATH = "/createRecipe"
PUT_RAW_PATH = "/addIngredient"
DELETE_RAW_PATH = "/deleteRecipe"

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket = 'recipestorage'
    filename = 'recipes.json'
    
    # Retreive the json file data
    recipeJson = s3.get_object(Bucket=bucket, Key=filename)
    data =  json.loads(recipeJson['Body'].read().decode('UTF-8'))
    
    
    if event["rawPath"] == GET_RAW_PATH:
        # GET request received
        return {"body": data, "status_code": 200}
    
    elif event["rawPath"] == CREATE_RAW_PATH:
        # POST request received
        newRecipe = {"name": event['queryStringParameters']['name'], "ingredients": []}
        
        # Verify the recipe name isn't in the database already
        for recipe in data["recipes"]:
            if recipe["name"] == event['queryStringParameters']['name']:
                return {"message": f"'{event['queryStringParameters']['name']}' is already in the database"}, 401 
        
        # Add the new recipe to the json file
        data["recipes"].append(newRecipe)
        
        # Convert and update the json file in s3
        uploadByteStream = bytes(json.dumps(data).encode('UTF-8'))
        s3.put_object(Bucket=bucket, Key=filename, Body=uploadByteStream)
        
        return {"body": data, "status_code": 200}
        
    elif event["rawPath"] == PUT_RAW_PATH:
        # Look for the recipe matching the requested name
        index = -1
        for i in range(len(data["recipes"])):
            if data["recipes"][i]["name"] == event['queryStringParameters']['name']:
                index = i
                break
            
        # The recipe was not found, return an error
        if index == -1:
            return {"message": f"'{event['queryStringParameters']['name']}' is not in the database"}, 401
            
        # Add the ingredient to the recipe
        data["recipes"][index]["ingredients"].append(event['queryStringParameters']["ingredient"])
        
        # Convert and update the json file in s3
        uploadByteStream = bytes(json.dumps(data).encode('UTF-8'))
        s3.put_object(Bucket=bucket, Key=filename, Body=uploadByteStream)
        
        return {"body": data, "status_code": 200}
        
    elif event["rawPath"] == DELETE_RAW_PATH:
        # Look for the recipe matching the requested name
        index = -1
        for i in range(len(data["recipes"])):
            if data["recipes"][i]["name"] == event['queryStringParameters']['name']:
                index = i
                break

        # The recipe was not found, return an error
        if index == -1:
            return {"message": f"'{event['queryStringParameters']['name']}' is not in the database"}, 401
    
        # Remove the recipe from the json file
        del data["recipes"][index]
        
        # Convert and update the json file in s3
        uploadByteStream = bytes(json.dumps(data).encode('UTF-8'))
        s3.put_object(Bucket=bucket, Key=filename, Body=uploadByteStream)
        
        return {"body": data, "status_code": 200}
