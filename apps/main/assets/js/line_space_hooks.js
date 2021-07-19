const LineSpaceHook = {
    mounted() {
        $(this.el).keypress(function(e) {
            var textVal = $(this).val();
            if(e.which == 13 && e.shiftKey) {

            }
            else if (e.which == 13) {
                e.preventDefault();
                document.getElementById("paper-plane").click();
            }
        });
    }

}

export default LineSpaceHook