const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    try {
        const requestBody = JSON.parse(event.body);
        const timestamp = new Date().getTime().toString();
        
        const todo = {
            id: `todo-${timestamp}`, // Simple ID using timestamp
            text: requestBody.text,
            completed: false,
            createdAt: new Date().toISOString()
        };
        
        // Add the item to DynamoDB
        const params = {
            TableName: 'Todos',
            Item: todo
        };
        
        await dynamoDB.put(params).promise();
        
        return {
            statusCode: 201,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "POST",
            },
            body: JSON.stringify(todo)
        };
    } catch (error) {
        console.error("Error adding todo:", error);
        return {
            statusCode: 500,
            headers: {
                "Access-Control-Allow-Origin": "*",
            },
            body: JSON.stringify({ message: "Failed to add todo" })
        };
    }
};