const CsvUpload = {
    mounted() {
        console.log("asd")
        this.el.addEventListener("change", e => {
            console.log(e)
            let infoArea = document.getElementById("file-upload-filename");
            toBase64(this.el.files[0]).then(base64 => {
                let hidden = document.getElementById("csv_data") // change this to the ID of your hidden input
                hidden.value = base64;
                hidden.focus() // this is needed to register the new value with live view
            });
            let fileName = this.el.files[0].name;
            infoArea.textContent = 'File name: ' + fileName;

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