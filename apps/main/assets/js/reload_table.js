const ReloadTable = {
    mounted() {
        console.log("asd")
        this.handleEvent("reload", ({}) => reload())
        this.handleEvent("init", ({}) => init())
    }
}
const init = function (){
    Looper.init()
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
export default ReloadTable;