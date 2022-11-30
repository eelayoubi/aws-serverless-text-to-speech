const AWS = require("aws-sdk");
const docClient = new AWS.DynamoDB.DocumentClient();
const polly = new AWS.Polly({
    signatureVersion: 'v4',
    region: 'us-east-1'
});
const fs = require("fs");
const s3 = new AWS.S3();

const POSTS_TABLE = process.env.POSTS_TABLE;
const BUCKET_NAME = process.env.BUCKET_NAME;

exports.handler = async (event, context, callback) => {
    console.log(event["Records"][0]);

    const postId = event["Records"][0]["Sns"]["Message"];

    console.log(`Text to Speech function. Post ID in DynamoDB: ${postId}`);

    try {

        const response = await getPostFromDDB(postId);

        console.log("DynamoDB Item: ", response);

        const chunksToRequest = splitTextToChunkRequests(response);

        console.log("chunksToRequest: ", chunksToRequest);

        for (let chunk of chunksToRequest) {
            const output = await polly.synthesizeSpeech(chunk).promise();
            fs.appendFileSync(`/tmp/${postId}`, output.AudioStream);
        }

        await s3.upload({
            Bucket: BUCKET_NAME,
            Key: `${postId}.mp3`,
            Body: fs.readFileSync(`/tmp/${postId}`),
            ACL: 'public-read'
        }).promise();

        console.log("Uploaded MP3 to S3 ...");

        const url = await getS3PostUrl(postId);

        const updateAudioPostStatus = await updatePost(postId, url);

        console.log("DynamoDB Updated Item: ", updateAudioPostStatus);
    } catch (error) {
        console.log('error:', error)
        const response = {
            "statusCode": 400,
            "body": JSON.stringify(error),
            "isBase64Encoded": false
        };
        return response;
    }
};

function getPostFromDDB(postId) {
    const params = {
        TableName: POSTS_TABLE,
        Key: {
            id: postId
        }
    };
    return docClient.get(params).promise();
}

function splitTextToChunkRequests(items) {
    const { text, voice } = items.Item;

    let textToSplit = text;
    const textChunks = [];

    while (textToSplit.length > 2600) {
        let textChunk;
        let end = textToSplit.indexOf(".", 2500);
        if (end == -1) {
            end = textToSplit.indexOf(".", 2500);
        }
        textChunk = textToSplit.substring(0, end + 1);
        textToSplit = textToSplit.substring(end + 1);
        textChunks.push(textChunk);
    }

    textChunks.push(textToSplit);
    let chunksToRequest = [];
    textChunks.forEach(chunk => {
        chunksToRequest.push({
            Text: chunk,
            VoiceId: voice,
            OutputFormat: "mp3"
        });
    });

    return chunksToRequest;
}

async function getS3PostUrl(postId) {
    const location = await s3.getBucketLocation({ Bucket: BUCKET_NAME }).promise();
    const region = location['LocationConstraint'];
    let url_prefix = '';

    console.log('Region: ', region, "Location: ", location);

    if (!region) {
        url_prefix = "https://s3.amazonaws.com/";
    } else {
        url_prefix = "https://s3-" + String(region) + ".amazonaws.com/";
    }

    const url = `${url_prefix}${BUCKET_NAME}/${postId}.mp3`;
    return url;
}

async function updatePost(postId, url) {
    const updateParams = {
        TableName: POSTS_TABLE,
        Key: {
            id: postId
        },
        UpdateExpression: "set #statusAtt= :statusValue, #urlAtt = :urlValue",
        ExpressionAttributeValues: {
            ":statusValue": "UPDATED",
            ":urlValue": url
        },
        ExpressionAttributeNames: {
            "#statusAtt": "status",
            "#urlAtt": "url"
        }

    };
    const updateAudioPostStatus = await docClient.update(updateParams).promise();
    return updateAudioPostStatus;
}