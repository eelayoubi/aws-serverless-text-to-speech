# aws-serverless-text-to-speech
AWS Serverless Text To Speech Application. This application is based on this [AWS workshop](https://explore.skillbuilder.aws/learn/course/1094/build-a-serverless-text-to-speech-application-with-amazon-polly).

The goal of this is to deploy a text-to-speech serverless application using **terraform**.

## Architecture
### New Post

![New Post](/assets/new-post.jpeg)

1. The user calls the API Gateway Restful endpoint that invokes the NewPost lambda function.
2. The NewPost Lambda function inserts information about the post into an Amazon DynamoDB table, where information about all posts is stored.
3. Then, the NewPost Lambda function publishes the post to the SNS topic we create, so it can be converted asynchronously.
4. Convert to Audio Lambda function, is subscribed to the SNS topic and is triggered whenever a new message appears (which means that a new post should be converted into an audio file).
5. The Convert to Audio Lambda function uses Amazon Polly to convert the text into an audio file in the specified language (the same as the language of the text).
6. The new MP3 file is saved in a dedicated S3 bucket.
7. Information about the post is updated in the DynamoDB table (the URL to the audio file stored in the S3 bucket is saved with the previously stored data.)

### Get Post

![Get Post](/assets/get-post.jpeg)

1. The user calls the API Gateway Restful endpoint that invokes the GetPost lambda function which contains the logic for retrieving the post data.
2. The GetPost Lambda function retrieves information about the post (including the reference to Amazon S3) from the DynamoDB table and returns the information.

## Deploying the application
### Prerequisites
- Make sure to have terraform installed prior to running the example. Feel free to refer to the [official page](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install it.


I am using the **us-east-1** as a region. You can change [here](./provider.tf#L16).

### Run

In the root directory, simply run:
```
terraform apply -auto-approve
```

You will see printed in the command line output the AWS Api Gateway invokation url, that will be used to access the application:
```
rest_api_url = "https://xxxxxxxxx.execute-api.us-east-1.amazonaws.com/dev/posts"
```

## Testing the application
After the application is deployed, it is time to test it out. As explained earlier, we have 2 scenarios:
1. Creating a new post
2. Getting Post(s)

### New Post
We will use the curl command to invoke the API resources.

```
curl --location --request POST 'https://xxxxxxxxx.execute-api.us-east-1.amazonaws.com/dev/posts' \
--header 'Content-Type: application/json' \
--data-raw '{
        "text": "Hello all, I am feeling great today",
        "voice": "Joanna"
    }'
```

As you can see, we are sending a Json Body with the Post method.

- **text** field: this is the text to convert to audio
- **voice** field: this is the voice used in the audio, you can pick one of [these voices](https://docs.aws.amazon.com/polly/latest/dg/voicelist.html)

The response to that call will be the Post ID in the DynamoDB table
```
"a94a0029-e000-4582-8c27-b73c6cc95356"
```

### Get Post
Using the curl command, we can get the post information we just created from dynamodb:
```
curl --location --request GET 'https://1w0evgft9c.execute-api.us-east-1.amazonaws.com/dev/posts?postId=a94a0029-e000-4582-8c27-b73c6cc95356'
```

And here is the response:
```
[
    {
        "text": "Hello all, I am feeling great toda",
        "id": "a94a0029-e000-4582-8c27-b73c6cc95356",
        "url": "https://s3.amazonaws.com/audio-posts-6tqysf3/a94a0029-e000-4582-8c27-b73c6cc95356.mp3",
        "voice": "Joanna",
        "status": "UPDATED"
    }
]
```

If we want to return all the posts, we can use the "*" insead of the post Id:
```
curl --location --request GET 'https://1w0evgft9c.execute-api.us-east-1.amazonaws.com/dev/posts?postId=*'
```

And here is the response: 
```
[
    {
        "text": "Hello all, I am feeling great toda",
        "id": "a94a0029-e000-4582-8c27-b73c6cc95356",
        "url": "https://s3.amazonaws.com/audio-posts-6tqysf3/a94a0029-e000-4582-8c27-b73c6cc95356.mp3",
        "voice": "Joanna",
        "status": "UPDATED"
    },
    {
        "text": "Hello all, I am enjoying this blog so much ...",
        "id": "4dc22814-ba00-4cc1-9321-c6549351c0b4",
        "url": "https://s3.amazonaws.com/audio-posts-6tqysf3/4dc22814-ba00-4cc1-9321-c6549351c0b4.mp3",
        "voice": "Salli",
        "status": "UPDATED"
    }
]
```

## Cleanup
Don't forget to clean everything up by running:

```
terraform destroy -auto-approve
```