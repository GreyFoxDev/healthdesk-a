
const Phone = {
    mounted() {
        // this.handleEvent("reload", ({}) => reload())
        var input = document.getElementById("phone");
        window.intlTelInput(input, {
          utilsScript: "https://cdn.jsdelivr.net/npm/intl-tel-input@17.0.3/build/js/utils.js"
        });
    },
    updated() {
        var input = document.getElementById("phone");
        window.intlTelInput(input, {
            utilsScript: "https://cdn.jsdelivr.net/npm/intl-tel-input@17.0.3/build/js/utils.js",
            initialCountry: "us",
            separateDialCode: true
        });

    }
}



export default Phone;