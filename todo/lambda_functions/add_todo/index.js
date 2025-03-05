// In-memory store - this is only for demonstration purposes
// In a real application, you would use DynamoDB or another persistent storage
let todos = [
  { id: '1', text: 'Learn Terraform', completed: false },
  { id: '2', text: 'Build serverless API', completed: false }
];

exports.handler = async (event) => {
  console.log('Adding a new todo');
  
  try {
    const requestBody = JSON.parse(event.body);
    
    if (!requestBody.text) {
      return {
        statusCode: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify({ error: 'Todo text is required' })
      };
    }
    
    const newTodo = {
      id: String(Date.now()),
      text: requestBody.text,
      completed: false
    };
    
    todos.push(newTodo);
    
    return {
      statusCode: 201,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ todo: newTodo })
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ error: 'Failed to add todo' })
    };
  }
};