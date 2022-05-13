import unittest

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
        event = {"rawPath": self.GET_RAW_PATH}
        context = 1

        res = lambda_handler(event, context)
        self.assertEqual(res['statusCode'], 200)

if __name__ == "__main__":
    unittest.main()
