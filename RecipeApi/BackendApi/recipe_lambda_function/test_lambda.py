from turtle import position
import unittest
import json

from lambda_function import lambda_handler


class TestLambdaMethods(unittest.TestCase):
    def setUp(self):
        self.GET_RAW_PATH = "/getRecipes"
        self.CREATE_RAW_PATH = "/createRecipe"
        self.PUT_RAW_PATH = "/updateRecipe"
        self.DELETE_RAW_PATH = "/deleteRecipe"
        self.jsonFile = "postRecipe.json"

    """
    GET Endpoint Tests
    """
    def test_get(self):
        res = self.get_recipes()
        self.assertEqual(res['statusCode'], 200)

    def test_get_no_ingredients(self):
        postBody = self.load_json()

        # Remove ingredients prior to POST
        postBody["ingredients"] = []

        # Set up lambda inputs
        event = {"rawPath": self.CREATE_RAW_PATH, "body": json.dumps(postBody)}
        context = 1

        # POST data
        post_res = lambda_handler(event, context)

        get_res = self.get_recipes()

        data = json.loads(post_res['body'])
        self.delete_recipe(data['recipeId'])

        self.assertEqual(get_res['statusCode'], 200)

    def test_get_no_images(self):
        postBody = self.load_json()

        # Remove ingredients prior to POST
        postBody["images"] = []

        # Set up lambda inputs
        event = {"rawPath": self.CREATE_RAW_PATH, "body": json.dumps(postBody)}
        context = 1

        # POST data
        post_res = lambda_handler(event, context)

        get_res = self.get_recipes()

        data = json.loads(post_res['body'])
        self.delete_recipe(data['recipeId'])

        self.assertEqual(get_res['statusCode'], 200)

    """
    POST Endpoint Tests
    """
    def test_post(self):
        postBody = self.load_json()

        # Set up lambda inputs
        event = {"rawPath": self.CREATE_RAW_PATH, "body": json.dumps(postBody)}
        context = 1

        # Call lambda funciton
        res = lambda_handler(event, context)
        try:
            data = json.loads(res['body'])
        except(ValueError):
            print(f"Error adding item to DB, response: {res}")
        
        self.delete_recipe(data['recipeId'])
        self.assertEqual(res['statusCode'], 200)

    def test_post_duplicate(self):
        postBody = self.load_json()

        # Set up lambda inputs
        event = {"rawPath": self.CREATE_RAW_PATH, "body": json.dumps(postBody)}
        context = 1

        # Call lambda funciton -> Call twice to check duplicate data
        res1 = lambda_handler(event, context)
        res2 = lambda_handler(event, context)


        data1 = json.loads(res1['body'])
        self.delete_recipe(data1['recipeId'])

        self.assertEqual(res2['statusCode'], 409)

    def test_post_same_name(self):
        postBody = self.load_json()

        # Set up lambda inputs
        event = {"rawPath": self.CREATE_RAW_PATH, "body": json.dumps(postBody)}
        context = 1

        # Post the first recipe
        res1 = lambda_handler(event, context)

        # Change the author prior to posting again
        postBody["author"] = "Fake Name"
        event = {"rawPath": self.CREATE_RAW_PATH, "body": json.dumps(postBody)}
        res2 = lambda_handler(event, context)


        data = json.loads(res1['body'])
        self.delete_recipe(data['recipeId'])
        data = json.loads(res2['body'])
        self.delete_recipe(data['recipeId'])

        self.assertEqual(res2['statusCode'], 200)

    def test_post_missing_param(self):
        test_keys = ["recipeName", "instructions", "author", "category", "ingredients", "images"]
        for key in test_keys:
            postBody = self.load_json()
            del postBody[key]

            # Set up lambda inputs
            event = {"rawPath": self.CREATE_RAW_PATH, "body": json.dumps(postBody)}
            context = 1

            # Call lambda funciton
            res = lambda_handler(event, context)
            data = json.loads(res['body'])
            self.delete_recipe(data['recipeId'])
            if res['statusCode'] != 200:
                self.assertEqual(res['statusCode'], 200)

        self.assertEqual(res['statusCode'], 200)

    """
    PUT Endpoint Tests
    """
    def test_put(self):
        putBody = self.load_json()

        # Add something to the database first
        data = self.post_recipe()
        putBody["recipeId"] = data["recipeId"]

        # Change something for PUT
        putBody["category"] = "Sauce"

        # Set up lambda inputs
        event = {"rawPath": self.PUT_RAW_PATH, "body": json.dumps(putBody)}
        context = 1

        # Call lambda funciton
        res = lambda_handler(event, context)
        try:
            data = json.loads(res['body'])
        except(ValueError):
            print(f"Error updating item in DB, response: {res}")
        
        self.delete_recipe(data['recipeId'])
        self.assertEqual(res['statusCode'], 200)

    def test_put_no_recipeId(self):
        putBody = self.load_json()
        
        # Add something to the database first
        data = self.post_recipe()

        # Send put without recipeId
        # Set up lambda inputs
        event = {"rawPath": self.PUT_RAW_PATH, "body": json.dumps(putBody)}
        context = 1

        # Call lambda funciton
        resPut = lambda_handler(event, context)

        self.delete_recipe(data['recipeId'])
        self.assertEqual(resPut['statusCode'], 400)

    def test_put_missing_params(self):
        # Add something to the database first
        data = self.post_recipe()

        test_keys = ["recipeName", "instructions", "author", "category"]
        for key in test_keys:
            putBody = data
            del putBody[key]

            # Set up lambda inputs
            event = {"rawPath": self.PUT_RAW_PATH, "body": json.dumps(putBody)}
            context = 1

            # Call lambda funciton
            res = lambda_handler(event, context)
            if res['statusCode'] != 200:
                print(res)
                self.delete_recipe(data['recipeId'])
                self.assertEqual(res['statusCode'], 200)

        self.delete_recipe(data['recipeId'])
        self.assertEqual(res['statusCode'], 200)

    def test_put_no_ingredients(self):
        # Add something to the database first
        data = self.post_recipe()
        del data["ingredients"]

        # Set up lambda inputs
        event = {"rawPath": self.PUT_RAW_PATH, "body": json.dumps(data)}
        context = 1

        # Call lambda funciton
        res = lambda_handler(event, context)
        try:
            data = json.loads(res['body'])
        except(ValueError):
            print(f"Error updating item in DB, response: {res}")
        
        self.delete_recipe(data['recipeId'])
        self.assertEqual(res['statusCode'], 200)


    """
    DELETE Endpoint Tests
    """

    """
    Helper methods
    """
    def load_json(self):
        with open(self.jsonFile) as f:
            body = json.load(f)
        
        return body

    def get_recipes(self):

        # Set up lambda inputs
        event = {"rawPath": self.GET_RAW_PATH}
        context = 1

        return lambda_handler(event, context)

    def post_recipe(self):
        postBody = self.load_json()
        # Set up lambda inputs
        event = {"rawPath": self.CREATE_RAW_PATH, "body": json.dumps(postBody)}
        context = 1

        # Call lambda funciton
        resPost = lambda_handler(event, context)
        try:
            return json.loads(resPost['body'])
        except(ValueError):
            print(f"Error adding item to DB, response: {resPost}")

    def delete_recipe(self, recipeId):
        # Set up lambda inputs
        event = {"rawPath": self.DELETE_RAW_PATH, "body": json.dumps({"recipeId": recipeId})}
        context = 1

        # TODO: Add an exception for when the DELETE fails
        res = lambda_handler(event, context)


if __name__ == "__main__":
    unittest.main()
