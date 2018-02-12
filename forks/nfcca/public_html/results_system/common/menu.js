// alert( 0 );
// **************************************************
function add_dates() {
    // **************************************************

    var select_object = document.getElementById("matchdate");
    var sdivision = document.getElementById("division");
    if (sdivision.selectedIndex >= 0) {
        var division = sdivision.options[sdivision.selectedIndex].value;
        var dates = all_dates[division];
	select_object.options.length = 0;
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

    // alert( 2 );
    add_dates();
    // alert( 3 );

}

// **************************************************
     function validate_menu_form() {
// **************************************************
       var i = 0;
       var f = document.menu_form;

       var validate_played_points = function(i) {
         if ( f["homeplayed"+i].value == "N" || f["awayplayed"+i].value == "N" ) {
           if ( f["hometotalpts"+i].value >0 || f["awaytotalpts"+i].value > 0 ) {
             alert( "This match was not played! Points should be 0. Match: " + i );
             return false;
           }  
         }
         return true;
       };

       var validate_won_lost = function(i) {
         if ( f["homeplayed"+i].value == "Y" || f["awayplayed"+i].value == "Y" ) {
           if ( f["homeresult"+i].value == f["awayresult"+i].value ) {
             if ( f["homeresult"+i].value.search( /[WL]/ ) >= 0 ) {
               alert( "If one team won, surely the other lost! Match: " + i );
               return false;
             }  
           }
	 }  
         return true;
       };

       var validate_not_played = function(i) {
           if ( f["home"+i].value == "" || f["away"+i].value == "" ) {
             if ( f["homeplayed"+i].value == "Y" || f["awayplayed"+i].value == "Y" ) {
               alert( "No fixture. Please set played to N. Match: " + i );
               return false;
             }
           }
           return true;
       };

       while ( f["homeplayed" + i] ) {
         if (validate_played_points(i) == false){
            return false;
         }
         if (validate_won_lost(i) == false){
            return false;
         }
         if (validate_not_played(i) == false){
            return false;
         }
         i++;
       }
       return true;
     }
     
// **************************************************
     function calculate_points( obj, i ) {
// **************************************************

       var ok = true;
       var check_int = function(i,m) { if (! Number.isInteger(parseInt(i))) { alert(m + " must be an integer. " + i ); ok=false; } };

       var name = obj.name;
       var venue;
       if ( name.search( /^home/ ) >= 0 ) {
         venue = "home";
       }
       else {
         venue = "away";
       }
       if ( document.menu_form[venue+"played"+i].value == "N" 
           && ( obj.value.search( /^[0-9]/ ) >= 0 ) 
           && obj.value > 0 ) {
         obj.value = "";
         alert( "This match has not been played!" );
         return;
       }
              
       var resultpts = document.menu_form[venue+"resultpts"+i].value;
       var battingpts = document.menu_form[venue+"battingpts"+i].value;
       var bowlingpts = document.menu_form[venue+"bowlingpts"+i].value;
       var penaltypts = document.menu_form[venue+"penaltypts"+i].value;

       resultpts = resultpts ? resultpts : 0
       battingpts = battingpts ? battingpts : 0;
       bowlingpts = bowlingpts ? bowlingpts : 0;
       penaltypts = penaltypts ? penaltypts : 0;

       check_int(battingpts,"batting points");
       check_int(bowlingpts,"bowling points");
       check_int(penaltypts,"penalty points");
       check_int(resultpts,"result points");

       if (ok==true){
         var totalpts = parseInt( resultpts ) + parseInt( battingpts ) + parseInt( bowlingpts ) - parseInt( penaltypts );
         document.menu_form[venue+"totalpts"+i].value = totalpts;
       }

     }

window.onload = set_up;
menu = 1;

