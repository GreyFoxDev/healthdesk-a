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
> export $(cat .env | xargs)
```

Next install the dependancies: 

```bash
> mix deps.get
```

## Install Lib Sass

```bash
> brew install libsass
```


