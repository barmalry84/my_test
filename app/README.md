# People Info API

## Intro

The People Info API is a small API based on Fastify and Typescript. API allows to receive data and posts it to DynamoDB. It also uses Redis cluster as cache layer between application and database.

## Prerequisites

- Node.js 20+
- DynamoDB already created and runs in AWS (**app_iac** stack)
- Redis cluster already created and runs in AWS (**app_iac** stack)

Note that current code implementation has DynamoDb and Redis as hard requirements. Application will fail to start without them.

## Running locally

```sh
npm install
cp .env.example .env
npm run start
```
Visit `localhost:3000/status` in browser

or

```sh
docker build -t people-info-api .
docker run -p 3000:3000 people-info-api
```

Note: 
1. If application runs locally, it will have issues with connecting to Redis cluster as it is running in AWS VPC. There are ways to workaround this:
- mock redis cluster while running locally 
- create IP forwarding via AWS NATs to Redis
- use VPN connection to VPC to access its internals.
- just comment Redis code part before running application locally.
In a scope of the task, it's proposed to use last option.
2. For running DynamoDb locally, it's possible to use [DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html). But in a scope of the task it was not done.

## Running in AWS (proposed way to test)
After **basic_iac** and **app_iac** stacks are created, next steps shall be done:
1. Find our endpodint of Redis cluster in AWS.
2. Important!!! Update host for redis cluster in **app/src/app.ts**.
3. Push to main branch.
4. Wait until workflow is done.
5. Find created ALB in AWS console or using terminal

## How to use app

Run the following command to verify the server status:

```bash
curl http://{ALB_URl}/status
```
**Expected**: Server status.

#### 2. Posting Data to `/data` Endpoint

**Request**:

Use the following `curl` command to post data:

```bash
curl -X POST http://{ALB_URl}/data -H "Content-Type: application/json" -d '{
  "person_name": "John",
  "person_surname": "Doe",
  "person_birthdate": "1990-01-01",
  "person_address": "123 Main St"
}'
```

**Expected**: Appropriate success response indicating the data has been saved/processed. The response should also reply with the data submitted.

#### 3. Retrieve Data by Surname

**Request**:

To get data by the restaurant name, use:

```bash
curl http://{ALB_URl}/data?person_surname=<Person Surname>
```

Replace `<Person Surname>` with the actual name of the person you wish to query.

**Expected**: JSON response containing the details related to the specified person.
s
#### 4. Retrieve Prometheus client metrics

```bash
curl http://{ALB_URl}/metrics
```

## Tests
Not implemented because task took all my dedicated time to it.

## DynamoDB vs Redis
1. Application saves data to DynamoDB and also puts it to Redis cache level. 
2. Get request is made to Redis first and then to DynamoDB.