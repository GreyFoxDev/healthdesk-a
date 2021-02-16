const NotificationHook = {
    mounted(){
        console.log("mounted");
    },
    updated() {
        console.log("updated");
        console.log(this.el);

        let newConversationLink = this.el.querySelector('[class="notifications"]')
        if (!newConversationLink) return

        let notification = new Notification(newConversationLink.innerText)
        notification.onclick = () => window.open(newConversationLink.firstElementChild.firstElementChild.href)
    }
}

export default NotificationHook