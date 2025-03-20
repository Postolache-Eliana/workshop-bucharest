import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  UpdateCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);

// Use the environment variable from Lambda configuration
const tableName = process.env.TODO_TABLE_NAME;

export const handler = async (event, context) => {
  let body;
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  };

  try {
    let requestBody = JSON.parse(event.body);
    await dynamo.send(
      new UpdateCommand({
        TableName: tableName,
        Key: {
          todoId: event.pathParameters.id,
        },
        UpdateExpression: 'SET #text = :text, #completed = :completed',
        ExpressionAttributeNames: {
          '#text': 'text',
          '#completed': 'completed'
        },
        ExpressionAttributeValues: {
          ':text': requestBody.text,
          ':completed': requestBody.completed
        },
      })
    );
    body = `Updated item ${event.pathParameters.id}`;
  } catch (err) {
    statusCode = err.statusCode;
    body = { message: err.message };
  } finally {
    body = JSON.stringify(body);
  }

  return {
    statusCode,
    body,
    headers,
  };
};