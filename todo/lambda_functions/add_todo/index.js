const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  PutCommand,
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(client);

// Use the environment variable from Lambda configuration
const tableName = process.env.TODO_TABLE_NAME;

exports.handler = async (event, context) => {
  console.log("TABLE NAME:", tableName);
  console.log("EVENT:", JSON.stringify(event));
  
  let body;
  let statusCode = 201;
  const headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  };

  try {
    const requestBody = JSON.parse(event.body);
    
    // Generate a unique ID with timestamp
    const timestamp = new Date().getTime();
    
    // Create the new todo item
    const todo = {
      ToDoId: `todo-${timestamp}`,
      text: requestBody.text,
      completed: false,
      createdAt: new Date().toISOString()
    };
    
    await dynamo.send(
      new PutCommand({
        TableName: tableName,
        Item: todo
      })
    );
    
    body = todo;
  } catch (err) {
    console.error("ERROR:", err);
    statusCode = 400;
    body = { message: "Bad request", error: err.message };
  } finally {
    body = JSON.stringify(body);
  }

  return {
    statusCode,
    body,
    headers,
  };
};