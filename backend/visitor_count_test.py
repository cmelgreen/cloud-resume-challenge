import unittest
import boto3
from moto import mock_dynamodb

TABLE = "visitorCount"

@mock_dynamodb
class TestLambdaFunction(unittest.TestCase):
    def setUp(self):
        self.dynamodb = boto3.client('dynamodb')
        try:
            self.table = self.dynamodb.create_table(
                TableName=TABLE,
                KeySchema=[
                    {'KeyType': 'HASH', 'AttributeName': 'id'}
                ],
                AttributeDefinitions=[
                    {'AttributeName': 'id', 'AttributeType': 'N'},
                ],
                ProvisionedThroughput={
                    'ReadCapacityUnits': 1,
                    'WriteCapacityUnits': 1
                }
            )
        except self.dynamodb.exceptions.ResourceInUseException:
            self.table = boto3.resource('dynamodb').Table(TABLE)

    def test_handler(self):
        from visitor_count import lambda_handler

        result = lambda_handler(None, None)

        assert result['StatusCode'] == 200

if __name__ == '__main__':
    unittest.main()
