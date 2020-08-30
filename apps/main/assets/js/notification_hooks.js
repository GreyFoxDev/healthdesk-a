const NotificationHook = {
    mounted(){
        this.handleEvent("new_msg", ({msg}) => {
            var localtion = msg.location
            var convo = msg.convo
            let notification = new Notification("New message for "+localtion.location_name)
            notification.onclick = () => window.open("/admin/teams/"+location.team_id+"/locations/"+location.id+"/conversations/"+convo+"/conversation-messages")
        })
    },
    updated() {
        let newConversationLink = this.el.querySelector('[class="notifications"]')
        if (!newConversationLink) return

        let notification = new Notification(newConversationLink.innerText)
        notification.onclick = () => window.open(newConversationLink.firstElementChild.firstElementChild.href)
    }
}

export default NotificationHook
