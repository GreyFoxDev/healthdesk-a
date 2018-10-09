# Chatbot


Chatbot is the message handler for the LegDay chatbot application.

To use the the chatbot application, call the `Chatbot.send/1` with a valid list of params.

```
# Example Params

%{
  provider: "twilio",
  from: "+1##########",
  to:  "+1##########",
  body: "Hello!"
}

```
