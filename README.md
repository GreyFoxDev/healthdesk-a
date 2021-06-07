# Healthdesk, Inc.

**TODO: Add description**

# Setup Instructions

## Getting the dependancies

You'll need to add environment variables for the following keys so that the Elixir project compiles:

```bash
TWILIO_ACCOUNT_SID=
TWILIO_AUTH_TOKEN=
AUTHY_API_KEY=
WIT_ACCESS_TOKEN=
```

One way is by creating a .env file that you can get into the environment as follows:

```bash
> export $(cat ..env | xargs)
```

Next install the dependancies:

```bash
> mix deps.get
```

## Install Node Modules

```bash
> cd ${projectRoot}/apps/main/assets/
> yarn
```

## Setup postgres

You can do this quickly using docker for a local dev setup:

```bash
docker run --name postgres-healthdesk -d -p 5432:5432 -e POSTGRES_PASSWORD=postgres -e POSTGRES_DATABASE=healthdesk_dev -e POSTGRES_USER=postgres postgres:alpine
```

## Run Migrations and Start the server

```bash
mix ecto.create
mix ecto.migrate
mix phx.server
```

## Testing locally with ngrok

Found [this][1] and it will be helpful for testing and local debugging.

Notes:
- Before step 3 on that page. Sign up/authorize on the [ngok][2] site and setup the authtoken they issue.
- The command to start the ngok server isn't `./ngrok <PORT>` it's actually `./ngrok http <PORT>`
- set a port of your choice with `export PORT=<PORT>` and the app will pick it up when it starts
- there is a route `/api/sms/inbound` that you can use to confirm that ngrok is working.

[1] https://www.twilio.com/blog/2013/10/test-your-webhooks-locally-with-ngrok.html
[2] https://ngrok.com/
