import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  DeleteCommand,
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
  };

  try {
    await dynamo.send(
      new DeleteCommand({
        TableName: tableName,
        Key: {
          todoId: event.pathParameters.id,
        },
      })
    );
    body = `Deleted item ${event.pathParameters.id}`;
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