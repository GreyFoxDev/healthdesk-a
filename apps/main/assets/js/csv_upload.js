const CsvUpload = {
    mounted() {
        console.log("asd")
        this.el.addEventListener("change", e => {
            console.log(e)
            toBase64(this.el.files[0]).then(base64 => {
                var hidden = document.getElementById("csv_data") // change this to the ID of your hidden input
                hidden.value = base64;
                hidden.focus() // this is needed to register the new value with live view
            });
        })
    }
}
const toBase64 = file => new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.readAsText(file);
    reader.onload = () => resolve(reader.result);
    reader.onerror = error => reject(error);
});
export default CsvUpload;