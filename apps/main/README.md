# Main

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Web Bot

To use the web bot add the following to your website:

```
<link href="https://netdna.bootstrapcdn.com/bootstrap/3.0.0/css/bootstrap.min.css" rel="stylesheet" id="bootstrap-css">
<script src="https://code.jquery.com/jquery-1.11.1.min.js"></script>
<script src="https://netdna.bootstrapcdn.com/bootstrap/3.0.0/js/bootstrap.min.js"></script>

<link href="http://localhost:4000/css/web-bot.css" rel="stylesheet">

<span class="open-button" id="web-bot-open" onclick="openForm()">
  <span class="glyphicon glyphicon-comment web-bot-open-icon"></span>
</span>
<div class="col-sm-3 col-sm-offset-4 frame chat-popup" id="web-bot">
  <span class="chat-popup-close" onclick="closeForm()">&nbsp;X&nbsp;</span>
  <ul id="web-bot-ul"></ul>
  <div>
    <div class="msj-rta macro">
      <div class="text text-r" style="background:whitesmoke !important">
        <input id="web-bot-msg" class="mytext" placeholder="Type a message..."/>
      </div>
    </div>
    <div style="padding:10px;">
      <span class="glyphicon glyphicon-share-alt" id="web-bot-send"></span>
    </div>
  </div>
</div>

<script>
  const web_bot_config = {
    "key": "40236dd9-3fd0-4d93-bfbb-458013cf1b99",
  }
</script>
<script src="https://healthdesk-ai.herokuapp.com/js/web-bot.js"></script>
```


## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
