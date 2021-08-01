$('body').on("click","#slide_right_btn", function () {
    $(".has-sidebar-expand-xl .page-sidebar").css({"transform":"translate3d(100%, 0, 0)"});
});
$('body').on("click","#slide_left_btn", function () {
    $(".conversation_details").css({"position":"fixed","transform":"translateZ(0)","top":"50px"});
});
$('body').on("click","#close_side_toggle", function () {
    $(".conversation_details").css({"position":"relative","transform":"translateZ(0)","top":"0px"});
});

$(document).ready(function() {

    Looper.stackedMenu != undefined && Looper.stackedMenu.init()

    var url = window.location;


    // Will only work if string in href matches with location
    $('.menu li a[href="'+ url +'"]').parent().addClass('has-active');

    // Will also work for relative and absolute hrefs
    $('.menu li a').filter(function() {
        return this.href == url;
    }).parent().addClass('has-active');

    $(".has-child").each(function() {
        if ($(this).has(".has-active").length) {
            // find the parent and add class ONLY if the "IF" is true
            $(this)
                .addClass("has-active");
        }
    });
    $('body').on("click","#conversation_scheduled", function () {
        if (conversation_scheduled.checked) {
            $(".form_date").show(500);
            $(".form_btn").html("Schedule");
            flatpickr("#conversation_send_at", {
                enableTime: true,
                dateFormat: "Y-m-d H:i"
            });

        } else {
            $(".form_date").hide(500);
            $(".form_btn").html("Send Now");
        }
    });
    $('body').on('submit', '.modal.fade.show form',() =>
        $('#newMsg').modal('hide')
    )
    $('body').on('click', '#update_member',function (e){
        e.preventDefault(); // prevent default action of link

        $.ajax({
            url: '/api/update-member',
            type: 'PUT',
            data: $("#member-form").serialize(),
            success: function (data) {
                alert("You have successfully updated the member data");
                // window.location.reload();
            },
            error: function (data) {
                var response = data.responseJSON.message;
                alert(response);
            }
        }); });

});

var globalContainer;

(function($) {

    $.fn.upCount = function(options, callback) {
        var settings = $.extend({
            startTime: null,
            offset: null,
            reset: null,
            resume: null
        }, options);

        // Save container
        var container = this;
        globalContainer = container.parent().html();

        /**
         * Change client's local date to match offset timezone
         * @return {Object} Fixed Date object.
         */
        var currentDate = function() {
            // get client's current date
            var date = new Date();

            // turn date to utc
            var utc = date.getTime() + (date.getTimezoneOffset() * 60000);

            // set new Date object
            var new_date = new Date(utc + (3600000 * settings.offset))

            return new_date;
        };

        // Are we resetting our counter?
        if (settings.reset) {
            reset();
        }

        // Do we need to start our counter at a certain time if we left and came back?
        if (settings.startTime) {
            resumeTimer(new Date(settings.startTime));
        }

        // Define some global vars
        var original_date = currentDate();
        //console.log(currentDate())
        var target_date = new Date('12/31/2020 12:00:00'); // Count up to this date

        // Reset the counter by destroying the element it was bound to
        function reset() {
            var timerContainer = $('[name=timerContainer]');
            timerContainer.empty().append(globalContainer).find('.time').empty().append('00');
        }

        // Given a start time, lets set the timer
        function resumeTimer(startTime) {
            // This takes the difference between the startTime provided and the current date.
            // If the difference was 4 days and 25 mins, thats where the timer would start from continuing to count up
        }

        // Start the counter
        function countUp() {

            // Set our current date
            var current_date = currentDate();

            // difference of dates
            var difference = current_date - original_date;

            if (current_date >= target_date) {
                // stop timer
                clearInterval(interval);
                if (callback && typeof callback === 'function') callback();
                return;
            }

            // basic math variables
            var _second = 1000,
                _minute = _second * 60,
                _hour = _minute * 60,
                _day = _hour * 24;

            // calculate dates
            var days = Math.floor(difference / _day),
                hours = Math.floor((difference % _day) / _hour),
                minutes = Math.floor((difference % _hour) / _minute),
                seconds = Math.floor((difference % _minute) / _second);

            // fix dates so that it will show two digets
            days = (String(days).length >= 2) ? days : '0' + days;
            hours = (String(hours).length >= 2) ? hours : '0' + hours;
            minutes = (String(minutes).length >= 2) ? minutes : '0' + minutes;
            seconds = (String(seconds).length >= 2) ? seconds : '0' + seconds;

            // based on the date change the refrence wording
            var ref_days = (days === 1) ? 'day' : 'days',
                ref_hours = (hours === 1) ? 'hour' : 'hours',
                ref_minutes = (minutes === 1) ? 'minute' : 'minutes',
                ref_seconds = (seconds === 1) ? 'second' : 'seconds';

            // set to DOM
            container.find('.days').text(days);
            container.find('.hours').text(hours);
            container.find('.minutes').text(minutes);
            container.find('.seconds').text(seconds);

        };

        // start
        interval = setInterval(countUp, 1000);
    };

})(jQuery);


// Resume our timer from a specific time
$('.countdown').upCount({
    startTime: '09/01/2015 12:00:00',
    resume: true
});

if ( $( "#messages" ).length ) {
    new Chart(document.getElementById("messages"), {
        type: 'doughnut',
        data: {
            labels: ["Sent","Received"],
            datasets: [
                {
                    label: "Messages",
                    backgroundColor: ["#6657cc", "#e5586a"],
                    data: [2500,2100]
                }
            ]
        },
        options: {
            legend: { display: false },

        }
    });
}

if ( $( "#nps" ).length ) {
    new Chart(document.getElementById("nps"), {
        type: 'pie',
        data: {
            labels: ["Promoters","Passive","Detractors"],
            datasets: [
                {
                    label: "Score",
                    backgroundColor: ["#6657cc", "#e5586a","#f6c23e"],
                    data: [5,4,3]
                }
            ]
        },
        options: {
            legend: { display: false },
        }
    });
}

if ( $( "#usersdata" ).length ) {
    new Chart(document.getElementById("usersdata"), {
        type: 'bar',

        data: {
            labels: ["Users"],
            datasets: [{
                label: 'Returning',
                backgroundColor: '#6657cc',
                stack: 'Stack 0',
                data: [
                    230
                ]
            }, {
                label: 'New',
                backgroundColor: '#e5586a',
                stack: 'Stack 0',
                data: [
                    329
                ]
            }, {
                label: 'Member',
                backgroundColor: '#f6c23e',
                stack: 'Stack 1',
                data: [
                    300
                ]
            }, {
                label: 'Leads',
                backgroundColor: '#1cc88a',
                stack: 'Stack 1',
                data: [
                    259
                ]
            }]
        },
        options: {
            legend: { display: false },
            tooltips: {
                mode: 'index',
                intersect: false
            },
            responsive: true,
            scales: {
                xAxes: [{
                    stacked: true,
                    barPercentage: 0.4
                }],
                yAxes: [{
                    stacked: true
                }]
            }
        }
    });
}


if ( $( "#timedata" ).length ) {
    new Chart(document.getElementById("timedata"), {
        type: 'bar',

        data: {
            labels: ["Time (minutes)"],
            datasets: [{
                label: 'First Time',
                backgroundColor: '#6657cc',
                stack: 'Stack 0',
                data: [
                    9
                ]
            }, {
                label: 'Response Time',
                backgroundColor: '#e5586a',
                stack: 'Stack 1',
                data: [
                    9.2
                ]
            }, {
                label: 'Handling Time',
                backgroundColor: '#f6c23e',
                stack: 'Stack 2',
                data: [
                    12
                ]
            }]
        },
        options: {
            legend: { display: false },
            tooltips: {
                mode: 'index',
                intersect: false
            },
            responsive: true,
            scales: {
                xAxes: [{
                    stacked: true,
                    barPercentage: 0.4
                }],
                yAxes: [{
                    stacked: true,
                }]
            }
        }
    });
}


// $(document).ready(function() {
//     $('#Tickets').DataTable( {
//         select: true,
//         "order": [[ 4, "desc" ]],
//         "columnDefs": [
//             { "orderable": false, "targets": "no-sort" },{ "width": "20%", "targets": 3 }
//         ],
//         "scrollCollapse": true,
//         "paging":   true,
//         "info":     true,
//     } );
// });
//
// $(document).ready(function() {
//     $('#Tickets2').DataTable( {
//         initComplete: function () {
//             this.api().columns().every( function () {
//                 var column = this;
//                 var select = $('<select><option value=""></option></select>')
//                     .appendTo( $(column.footer()).empty() )
//                     .on( 'change', function () {
//                         var val = $.fn.dataTable.util.escapeRegex(
//                             $(this).val()
//                         );
//
//                         column
//                             .search( val ? '^'+val+'$' : '', true, false )
//                             .draw();
//                     } );
//
//                 column.data().unique().sort().each( function ( d, j ) {
//                     select.append( '<option value="'+d+'">'+d+'</option>' )
//                 } );
//             } );
//         },
//         "columnDefs": [
//             { "orderable": false, "targets": "no-sort" },{ "width": "20%", "targets": 3 }
//         ]
//     } );
// } );


$(document).ready(function() {
    $('#agentData').DataTable( {
        "columnDefs": [
            { "width": "50%", "targets": 0 }
        ],
        "scrollY":        "350px",
        "scrollCollapse": true,
        "paging":   false,
        "searching": false,
        "info":     false,
    });
} );

$(document).ready(function() {
    $('#campaignData').DataTable( {
        "order": [[ 3, "asc" ]],
        "columnDefs": [
            { "orderable": false, "targets": "no-sort" }
        ],
        "scrollCollapse": true,
        "searching": false,
        "responsive": true,
        "paging":   false,
        "info":     false
    });
} );


$(document).ready(function() {
    $('#callData').DataTable( {
        "scrollCollapse": true,
        "searching": false,
        "responsive": true,
        "paging":   false,
        "info":     false,
    });
} );

if ( $( "#nps2" ).length ) {
    new Chart(document.getElementById("nps2"), {
        type: 'doughnut',
        data: {
            labels: ["NPS","Rest"],
            datasets: [
                {
                    label: "Score",
                    backgroundColor: ["#6657cc"],
                    data: [18,82]
                }
            ]
        },
        options: {
            tooltips: {
                enabled: false
            },
            cutoutPercentage: 80,
            rotation: -Math.PI,
            circumference: Math.PI,
            legend: { display: false },
        },
    });
}
if ( $( "#nps3" ).length ) {
    new Chart(document.getElementById("nps3"), {
        type: 'horizontalBar',
        data: {
            labels: ["Promoters","Passive","Detractors"],
            datasets: [
                {
                    label: "Score",
                    backgroundColor: ["#6657cc", "#e5586a","#f6c23e"],
                    data: [5,4,3]
                }
            ]
        },
        options: {
            scales: {
                xAxes: [{
                    ticks: {
                        max: 10,
                        min: 0,
                        stepSize: 1
                    }
                }]
            },
            responsive: true,
            legend: { display: false },
        }
    });
}

if ( $( "#sessions2" ).length ) {
    new Chart(document.getElementById("sessions2"), {
        type: 'line',
        data: {
            labels: ['May 29','May 30','Jun 1','Jun 2','Jun 3','Jun 4','Jun 5'],
            datasets: [{
                data: [1300,1405,1400,1450,1400,1410,1350],
                label: "Facebook",
                backgroundColor: "#6657cc",
                borderColor: "#6657cc",
                fill: false
            }, {
                data: [1200,1500,1350,1400,1450,1300,1350],
                label: "SMS",
                backgroundColor: "#e5586a",
                borderColor: "#e5586a",
                fill: false
            }, {
                data: [1250,950,1155,1060,1045,1150,959],
                label: "Web",
                backgroundColor: "#f6c23e",
                borderColor: "#f6c23e",
                fill: false
            }, {
                data: [1030,1240,1350,1460,1200,1140,1450],
                label: "In-App",
                backgroundColor: "#1cc88a",
                borderColor: "#1cc88a",
                fill: false
            }, {
                data: [1033,1044,955,950,1000,855,900],
                label: "Phone",
                backgroundColor: "#36b9cc",
                borderColor: "#36b9cc",
                fill: false
            }
            ]
        },
        options: {
            hover: {
                mode: 'nearest',
                intersect: true
            },
            scales: {
                xAxes: [{
                    display: true
                }],
                yAxes: [{
                    display: true,
                    ticks: {


                        // forces step size to be 5 units
                        stepSize: 100,
                    }
                }]
            },
            legend: { display: false },
            tooltips: {
                mode: 'index',
                intersect: false
            }
        }
    });
}


$("#applylocations").on("click", function(){
    if(applylocations.checked) {
        $( ".locations" ).hide(500);
    } else {
        $( ".locations" ).show(500);
    }
});
