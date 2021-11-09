import Inputmask from"inputmask";

const Phone = {
    mounted() {
        // this.handleEvent("reload", ({}) => reload())
        var input = document.getElementById("phone");
        window.intlTelInput(input, {
          utilsScript: "https://cdn.jsdelivr.net/npm/intl-tel-input@17.0.3/build/js/utils.js"
        });
    },
    updated() {
        const format_mask=(str)=>{
            var newStr="";
            for (var i = 0; i<str.length; i++){
                if(str.charAt(i)==='-'){
                    newStr += '-'
                }
                else if (str.charAt(i)===' '){
                    newStr += ' '
                }
                else{
                    newStr += '9'
                }
            }
            return newStr;
        }
        var input = document.getElementById("phone");
        var iti= window.intlTelInput(input, {
            utilsScript: "https://cdn.jsdelivr.net/npm/intl-tel-input@17.0.3/build/js/utils.js",
            initialCountry: "us",
            separateDialCode: true
        });
        var istr=input.placeholder;
        if(istr){
            var newStr= format_mask(istr);
            Inputmask(newStr).mask(input);
        }
        input.addEventListener("countrychange", function() {
            // do something with iti.getSelectedCountryData()
            var str=input.placeholder;
            var newStr=format_mask(str)
            Inputmask(newStr).mask(input);
        });
    }
}



export default Phone;