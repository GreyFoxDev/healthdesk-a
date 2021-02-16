// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"
import NotificationHook from "./notification_hooks";
import CsvUpload from "./csv_upload";
import ReloadTable from "./reload_table";

let Hooks = { NotificationHook, CsvUpload, ReloadTable };

let scrollAt = () => {
    let elem = $(".board")[0]
    let scrollTop = elem.scrollTop
    let scrollHeight = elem.scrollHeight
    let clientHeight = elem.clientHeight
    console.log(scrollTop)
    console.log(scrollHeight-clientHeight)
    return scrollTop / (scrollHeight - clientHeight) * 100
}

Hooks.InfiniteScroll = {
    page() {
        return parseInt(this.el.dataset.page)
    },
    mounted(){
        this.pending = this.page()
        $(".board").on("scroll", e => {
            console.log("page:")
            console.log(this.page())
            console.log(this.page())
            if(this.pending === this.page() && scrollAt() > 95){
                console.log("HELP HELP HELP")
                this.pending = this.page() + 1
                console.log("------------start------------");
                console.log(this.pending);
                console.log("----------end----------------");
                this.pushEventTo("#scrolll","loadmore", {page: this.pending})
            }
        })
    },
    updated(){
        this.pending = this.page()
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken},hooks: Hooks });
liveSocket.connect()
if(Notification.permission != "denied" && Notification.permission != "granted") {
    Notification.requestPermission()
}
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"