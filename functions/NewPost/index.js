const AWS = require("aws-sdk");
const uuid4 = require("uuid4");
const docClient = new AWS.DynamoDB.DocumentClient();
const sns = new AWS.SNS();

const POSTS_TABLE = process.env.POSTS_TABLE;
const SNS_TOPIC = process.env.SNS_TOPIC;

exports.handler = async (event, context, callback) => {
  console.log("New Post: ", event);
  const recordId = uuid4();
  const params = {
    TableName: POSTS_TABLE,
    Item: {
      id: recordId,
      text: event.text,
      voice: event.voice,
      status: 'PROCESSING'
    }
  };

  try {
    await docClient.put(params).promise();
    const snsParams = {
      Message: recordId,
      TopicArn: SNS_TOPIC

    };

    console.log("Post added to DynamoDB for Processing");

    await sns.publish(snsParams).promise();

    console.log("Post published to SNS for Processing");

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
  return recordId;
};
