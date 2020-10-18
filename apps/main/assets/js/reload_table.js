const ReloadTable = {
    mounted() {
        console.log("asd")
        this.handleEvent("reload", ({}) => reload())
        this.handleEvent("init", ({}) => init())
        this.handleEvent("reload_convo", ({}) => reload_convo())
        this.handleEvent("init_convo", ({}) => init_convo())
        this.handleEvent("menu_fix", ({}) => menu_fix())
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
            availableMembers.push({value: tag, key: span[1].innerText})

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
    tribute2.collection[0].values=availableMembers
    tribute.collection[0].values=availableTags
    tribute2.attach($('[id^="tag_user"]')[0]);
    if ($('[id^="messagetext"]')[0] != undefined) {
        tribute.attach($('[id^="messagetext"]')[0]);
    }
    $('.perfect-scrollbar:not(".aside-menu")').each(function() {
        new PerfectScrollbar(this, {
            suppressScrollX: true
        });
    });

}

const menu_fix = function (){
    Looper.stackedMenu.init()

}
export default ReloadTable;