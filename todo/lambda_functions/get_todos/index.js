const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  ScanCommand,
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);

// Use the environment variable from Lambda configuration
const tableName = process.env.TODO_TABLE_NAME;

exports.handler = async (event, context) => {
  console.log("TABLE NAME:", tableName);
  console.log("EVENT:", JSON.stringify(event));
  
  let body;
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  };

  try {
    const response = await dynamo.send(
      new ScanCommand({ TableName: tableName })
    );
    body = response.Items;
  } catch (err) {
    console.error("ERROR:", err);
    statusCode = 500;
    body = { message: "Internal server error", error: err.message };
  } finally {
    body = JSON.stringify(body);
  }

  return {
    statusCode,
    body,
    headers,
  };
};