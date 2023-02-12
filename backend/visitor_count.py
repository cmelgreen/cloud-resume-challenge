import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitorCount')


def lambda_handler(event, context):
    response = table.update_item(
        Key={
            'id': 1
        },
        UpdateExpression='ADD visitorCount :inc',
        ExpressionAttributeValues={
            ':inc': 1
        },
        ReturnValues='UPDATED_NEW'
    )

    return {
        'statusCode': 200,
        'body': response['Attributes']['visitorCount']
    }
