const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.handler = async (event) => {
    try {
        // Scan the table to get all items
        const params = {
            TableName: 'Todos'
        };
        
        const result = await dynamoDB.scan(params).promise();
        
        return {
            statusCode: 200,
            headers: {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET",
            },
            body: JSON.stringify(result.Items)
        };
    } catch (error) {
        console.error("Error fetching todos:", error);
        return {
            statusCode: 500,
            headers: {
                "Access-Control-Allow-Origin": "*",
            },
            body: JSON.stringify({ message: "Failed to fetch todos" })
        };
    }
};