const ALPHABET = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
const ID_LENGTH = 8;
function generate() {
    var rtn = '';
    for (var i = 0; i < ID_LENGTH; i++) {
        rtn += ALPHABET.charAt(Math.floor(Math.random() * ALPHABET.length));
    }
    return rtn;
}
const room = generate();
const url = "wss://healthdesk-ai.herokuapp.com/socket/websocket";
const socket = new WebSocket(url);

var timerId = 0;

function keepAlive() {
    var timeout = 20000;
    if (socket.readyState == socket.OPEN) {
        socket.send(JSON.stringify({
            "topic": "web_bot:" + room,
            "event": "ping",
            "payload": {"message": "__ping__", "key": web_bot_config.key},
            "ref": "sdkfml"
        }));
    }
    timerId = setTimeout(keepAlive, timeout);
}

function cancelKeepAlive() {
    if (timerId) {
        clearTimeout(timerId);
    }
}

function connect() {
    socket.onopen = () => {
        socket.send(JSON.stringify({
            "topic": "web_bot:" + room,
            "event": "phx_join",
            "payload": {"key": web_bot_config.key},
            "ref": "lfskj"
        }));
        keepAlive();
    };
    openForm();
}
connect();

socket.onclose = () => {
    console.log("Connection closed");
    cancelKeepAlive();
};

socket.addEventListener("message", (event) => {
    var payload = JSON.parse(event.data).payload;
    if (payload.message && payload.message !== "__pong__") {
        insertChat(payload.from, payload.message, Date.now());
    }
});

function send() {
    var msg = document.getElementById("web-bot-msg");
    if (msg.value !== "") {
        connect();
        insertChat("me", msg.value, Date.now());

        socket.send(JSON.stringify({
            "topic": "web_bot:" + room,
            "event": "shout",
            "payload": {"message": msg.value, "key": web_bot_config.key},
            "ref": "sdkfml"
        }));
        document.getElementById("web-bot-msg").value = "";
    }
}

function openForm() {
    document.getElementById("web-bot-open").style.display = "none";
    document.getElementById("web-bot").style.display = "block";
}

function closeForm() {
    document.getElementById("web-bot-open").style.display = "block";
    document.getElementById("web-bot").style.display = "none";
}

document.getElementById("web-bot-send").addEventListener('click', function (e) { send(); });

document.getElementById("web-bot-msg").addEventListener('keypress', function (e) {
    if (e.keyCode == 13) {
        send();
    }
}, false);

function formatAMPM(date) {
    var hours = date.getHours();
    var minutes = date.getMinutes();
    var ampm = hours >= 12 ? 'PM' : 'AM';
    hours = hours % 12;
    hours = hours ? hours : 12; // the hour '0' should be '12'
    minutes = minutes < 10 ? '0'+minutes : minutes;
    var strTime = hours + ':' + minutes + ' ' + ampm;
    return strTime;
}

function insertChat(who, text, time){
    if (time === undefined){
        time = 0;
    }
    var control = "";
    var date = formatAMPM(new Date());

    if (who == "me"){
        control = '<li style="width:100%">' +
            '<div class="msj-rta macro">' +
            '<div class="text text-r">' +
            '<p>'+text+'</p>' +
            '<p>'+who+' <small>'+date+'</small></p>' +
            '</div>' +
            '</div>' +
            '</li>';
    }else{
        control = '<li style="width:100%;">' +
            '<div class="msj macro">' +
            '<div class="text text-l">' +
            '<p>'+text+'</p>' +
            '<p>Website Bot <small>'+date+'</small></p>' +
            '</div>' +
            '</li>';
    }
    $("#web-bot ul").append(control).scrollTop($("#web-bot ul").prop('scrollHeight'));

}
