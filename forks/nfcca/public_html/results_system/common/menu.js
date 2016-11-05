// alert( 0 );
// **************************************************
function add_dates() {
    // **************************************************

    var select_object = document.getElementById("matchdate");
    var sdivision = document.getElementById("division");
    if (sdivision.selectedIndex >= 0) {
        var division = sdivision.options[sdivision.selectedIndex].value;
        var dates = all_dates[division];
        for (x = 0; x < dates.length; x++) {
            var opt = new Option(dates[x], dates[x]);
            select_object.options[select_object.options.length] = opt;
        }
    }

}

// **************************************************
function set_up() {
    // **************************************************

    var sdivision = document.getElementById("division");
    // alert( menu_names.length + " divisions" );
    for (var x = 0; x < menu_names.length; x++) {

        var o = new Option(menu_names[x], csv_files[x]);
        sdivision.options[sdivision.options.length] = o;

    }

    //alert( 2 );
    add_dates();
    //alert( 3 );

}

window.onload = set_up;
menu = 1;

// alert( 1 );
