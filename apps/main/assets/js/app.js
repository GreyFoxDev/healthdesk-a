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
import LineSpaceHook from "./line_space_hooks";
import CsvUpload from "./csv_upload";
import ReloadTable from "./reload_table";
import LiveViewHook from "./live_view_hooks";
import Phone from './phone';


let Hooks = {LineSpaceHook, NotificationHook, CsvUpload, ReloadTable, LiveViewHook,Phone};


let scrollAt = () => {
    let elem = $(".board")[0]
    let scrollTop = elem.scrollTop
    let scrollHeight = elem.scrollHeight
    let clientHeight = elem.clientHeight

    return scrollTop / (scrollHeight - clientHeight) * 100
}

Hooks.InfiniteScroll = {
    page() {
        return parseInt(this.el.dataset.page)
    },
    mounted(){
        this.pending = this.page()
        $(".board").on("scroll", e => {
            if(this.pending === this.page() && scrollAt() > 95){
                this.pending = this.page() + 1
                this.pushEventTo("#scrolll","loadmore", {page: this.pending})
            }
        })
        // $('.board').animate({scrollTop: $('.list-group').length.offset().top}, 100)
    },
    updated(){
        this.pending = this.page()
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken},hooks: Hooks });
liveSocket.connect()
if(Notification.permission !== "denied" && Notification.permission !== "granted") {
    Notification.requestPermission()
}
// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"