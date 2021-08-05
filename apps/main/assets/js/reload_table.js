const ReloadTable = {
    mounted() {
        console.log("asd")
        this.handleEvent("reload", ({}) => reload())
        this.handleEvent("init", ({}) => init())
        this.handleEvent("reload_convo", ({}) => reload_convo())
        this.handleEvent("init_convo", ({}) => init_convo())
        this.handleEvent("menu_fix", ({}) => menu_fix())
        this.handleEvent("scroll_chat", ({}) => scroll_chat())
        this.handleEvent("init_ticket", ({}) => init_ticket())
        this.handleEvent("close_new", ({}) => close_new())
        this.handleEvent("open_edit", ({}) => open_edit())
        this.handleEvent("close_edit", ({}) => close_edit())
    }
}
const init = function (){
    menu_fix();
    $('#campaignData1').DataTable( {
        "scrollCollapse": true,
        "responsive": true,
        "info":     false,
        "destroy":     true,
        "searching": true,
        "ordering": false,
        "retrieve": true
    });
}
const reload = function (){
    let tb= $('#campaignData1').DataTable();
    tb.destroy(false)
    $('#campaignData1').DataTable( {
        "scrollCollapse": true,
        "responsive": true,
        "info":     false,
        "destroy":     true,
        "searching": true,
        "ordering": false,
        "retrieve": true
    });
}
const init_convo = function (){
    menu_fix();

}
const reload_convo = function (){
    Looper.init()
    var div = document.getElementsByClassName("message-body")[0]
    div.scrollTop = div.scrollHeight;
    var div = $("#message-files .card-body")[0]
    div.scrollTop = div.scrollHeight;
    var availableMembers = [];
    var availableTags = [];
    $("#availableMembers p").each(function (i, elem) {
        let span = $(elem).find('span');
        if (span.length) {
            var tag = "@" + span[1].innerText;
            availableMembers.push({id: span[0].innerText, value: tag, key: span[1].innerText})

        }
    });
    $("#availableTags p").each(function (i, elem) {
        let span = $(elem).find('span');
        if (span.length) {
            availableTags.push({value: span[0].innerText, key: span[1].innerText})
        }
    });
    var tribute = new Tribute({
        trigger: '#',
        selectTemplate: function (item) {
            return item.original.value;
        },
        values: []
    });
    var tribute2 = new Tribute({
        trigger: '@',
        selectTemplate: function (item) {
            return item.original.value;
        },
        values: []
    });

    tribute2.collection[0].values = remove_duplicates(availableMembers, "id")
    tribute.collection[0].values = remove_duplicates(availableTags, "key")


    $(document).on("input",'[name="conversation_message[message]"]',function (){
        this.style.height = "";
        this.style.height = this.scrollHeight + "px";
    })
    tribute2.attach($('[id^="tag_user"]')[0]);
    tribute2.attach($('[id^="taguser"]')[0]);

    if ($('[id^="taguser"]')[0] != undefined) {
        tribute.attach($('[id^="taguser"]')[0]);
    }
    if ($('[id^="tag_user"]')[0] != undefined) {
        tribute.attach($('[id^="tag_user"]')[0]);
    }
    $('.perfect-scrollbar:not(".aside-menu")').each(function() {
        new PerfectScrollbar(this, {
            suppressScrollX: true,
            wheelSpeed: 0.05,
            swipeEasing: true
        });
    });

}

const menu_fix = function (){
    Looper.stackedMenu.init()

}
const init_ticket = function (){
    let tb= $('.Tickets2').DataTable();
    $('.Tickets2').DataTable( {
        "scrollCollapse": true,
        "responsive": true,
        "info":     false,
        "destroy":     true,
        "searching": true,
        "ordering": false,
        "retrieve": true
    });
    var availableMembers = [];
    $("#availableMembers p").each(function (i, elem) {
        let span = $(elem).find('span');
        if (span.length) {
            var tag = "@" + span[1].innerText;
            availableMembers.push({value: tag, key: span[1].innerText})



        }
    });
    var tribute2 = new Tribute({
        trigger: '@',
        selectTemplate: function (item) {
            return item.original.value;
        },
        values: []
    });
    tribute2.collection[0].values=availableMembers
    tribute2.attach($('[id^="note_input"]')[0]);
    menu_fix();
}
const scroll_chat = function (){
    var div = document.getElementsByClassName("message-body")[0]
    div.scrollTop = div.scrollHeight;

}
const close_new = function (){
    $("#newTicket").modal('hide')
}
const close_edit = function (){
    $("#editTicket").modal('hide')
}
const open_edit = function (){
    $("#editTicket").modal('show')
}

const remove_duplicates = function(array, prop) {
    let newArray = [];
    let lookupObject  = {};

    for(let i in array) {
        lookupObject[array[i][prop]] = array[i];
    }

    for(let i in lookupObject) {
        newArray.push(lookupObject[i]);
    }
    return newArray;
}
export default ReloadTable;