const AWS = require("aws-sdk");
const docClient = new AWS.DynamoDB.DocumentClient();

const POSTS_TABLE = process.env.POSTS_TABLE;

exports.handler = async (event, context, callback) => {
  const postId = event["postId"];
  console.log("Getting data for post: ", postId);
  try {
    let response;
    if (postId === "*") {
      console.log("Initiating a SCAN request...");
      response = await docClient.scan({ TableName: POSTS_TABLE }).promise();
    } else {
      console.log("Initiating a GET request...");
      response = await docClient.query({
        TableName: POSTS_TABLE,
        KeyConditionExpression: 'id = :hkey',
        ExpressionAttributeValues: {
          ':hkey': postId
        }
      }).promise();
    };

    console.log("Returning response: ", response);
    return response.Items;
  } catch (error) {
    console.log('error=>>>>>>', error);
    const response = {
      errorType: "Error",
      statusCode: error.statusCode,
      message: error.message,
      requestId: context.awsRequestId,
    }
    callback(JSON.stringify(response));
  }
};
