const LiveViewHook = {
    page() {
        return this.el.dataset.time
    },
    mounted() {
        console.log("Live View Hooks Mounted")
        let time = this.page()
        let t = new Date(time);
        let c = new Date();

        let diff = c - t;
        setInterval(function(){diff = convertTime(diff);}, 1000)
    }
}

const convertTime = function convertTime(duration) {
    let milliseconds = parseInt((duration % 1000) / 100),
        seconds = Math.floor((duration / 1000) % 60),
        minutes = Math.floor((duration / (1000 * 60)) % 60),
        hours = Math.floor((duration / (1000 * 60 * 60)) % 24);

    hours = (hours < 10) ? "0" + hours : hours;
    minutes = (minutes < 10) ? "0" + minutes : minutes;
    seconds = (seconds < 10) ? "0" + seconds : seconds;

    document.getElementById('timer').innerHTML = hours + ":" + minutes + ":" + seconds;

    return duration + 1000;
}

export default LiveViewHook;