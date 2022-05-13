import unittest
import json

from lambda_function import lambda_handler

class TestLambdaMethods(unittest.TestCase):
    def setUp(self):
        self.GET_RAW_PATH = "/getRecipes"
        self.CREATE_RAW_PATH = "/createRecipe"
        self.PUT_RAW_PATH = "/addIngredient"
        self.DELETE_RAW_PATH = "/deleteRecipe"

    """
    GET Endpoint Tests
    """

    def test_get(self):
        # Set up lambda inputs
        event = {"rawPath": self.GET_RAW_PATH}
        context = 1

        res = lambda_handler(event, context)
        self.assertEqual(res['statusCode'], 200)

    """
    POST Endpoint Tests
    """
    def test_post(self):
        # Get data from json file
        with open("postRecipe.json") as f:
            postBody = json.load(f)

        # Set up lambda inputs
        
        event = {"rawPath": self.CREATE_RAW_PATH, "body": json.dumps(postBody)}
        context = 1

        # Call lambda funciton
        res = lambda_handler(event, context)
        self.assertEqual(res['statusCode'], 200)

    """
    PUT Endpoint Tests
    """

    """
    DELETE Endpoint Tests
    """
    

if __name__ == "__main__":
    unittest.main()