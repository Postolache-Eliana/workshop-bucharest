// In-memory store - this is only for demonstration purposes
// In a real application, you would use DynamoDB or another persistent storage
let todos = [
  { id: '1', text: 'Learn Terraform', completed: false },
  { id: '2', text: 'Build serverless API', completed: false }
];

exports.handler = async (event) => {
  console.log('Getting all todos');
  
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({ todos: todos })
  };
};