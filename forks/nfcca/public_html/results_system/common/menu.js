// alert( 0 );
// **************************************************
function add_dates( select_object ) {
// **************************************************

  var x=0; var d; var m; var l;
  var m = new Array ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
  
  // alert( gFirstSaturday );
  
  d = new Date(Date.parse(gFirstSaturday));
  l = new Date(Date.parse(gLastSaturday));
  while ( x < 28 && d.getTime() <= l.getTime() )
  {
  
    mon=m[d.getMonth()];
    var opt = new Option( d.getDate() + "-" + mon, d.getDate() + "-" + mon );
    // select_object.add( opt, null ); add worked on Netscape but not IE.
    select_object.options[select_object.options.length] = opt;
   
    x=x+1;
    d = new Date(d.getTime() + (7*86400000));

  }    

}

// **************************************************
function set_up() {
// **************************************************

  //alert( 2 );
  var sdate = document.getElementById( "matchdate" );
  add_dates( sdate );
  //alert( 3 );
  
  var sdivision = document.getElementById( "division" );
  // alert( menu_names.length + " divisions" );
  for ( var x = 0; x < menu_names.length; x++ ) {
  
    var o = new Option( menu_names[x], csv_files[x] );
    sdivision.options[sdivision.options.length] = o;
    
  }
  
}

window.onload = set_up;
menu = 1;

// alert( 1 );