import unittest
from mock import patch, MagicMock
import boto3
import json

class TestLambdaHandler(unittest.TestCase):

    def test_lambda_handler(self):
        with patch.object(boto3, 'resource') as mock_boto3_resource:
            mock_table = MagicMock()
            mock_boto3_resource.return_value = mock_table

            mock_response = {
                'Attributes': {
                    'visitorCount': 5
                }
            }
            mock_table.update_item.return_value = mock_response

            from visitor_count import lambda_handler

            response = lambda_handler(None, None)
            
            self.assertEqual(response['statusCode'], 200)
            self.assertEqual(json.loads(response['body']), 5)

            mock_table.update_item.assert_called_once_with(
                Key={
                    'visitorCount': 1
                },
                UpdateExpression='ADD visitorCount :inc',
                ExpressionAttributeValues={
                    ':inc': 1
                },
                ReturnValues='UPDATED_NEW'
            )

if __name__ == '__main__':
    unittest.main()
