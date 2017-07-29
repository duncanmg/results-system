//**********************************************************************
//
// Name: common.js
//
// Function:
//
// Copyright Duncan Garland Consulting Ltd 2003 - All rights reserved.
//
//**********************************************************************

gPointsForWin=12;
gPointsForDefeat=0;
gPointsForTie=6;
gPointsForAbandoned=0;

gMaxBattingPoints=7;
gMaxBowlingPoints=5;

gFirstSaturday='3 May 2008';
gLastSaturday='30 Aug 2008';

gSubmitFlag=0; // Used by cToggleFlag()

// Configuration script file.
g_configuration_file = "../custom/configuration.js";
var cgi_path;

////**********************************************************************
//function dp(num, precision)
////**********************************************************************
//{
//  x = num.toString().search(/\./);
//  //alert("num=" + num + " " + "x=" + x);
//  if (x>=0) { ret = num.toString().substr(0, x + precision + 1); }
//  else {ret=num;}
//  y=0; test=5;
//  while (y<=precision)
//  {
//    test = test/10;
//    y++;
//  }
//  ret = ret * 1.0;
//  //alert ("num=" + num + " ret=" + ret + " test=" + test);
//  if ( num*1 > ret*1.0 + test*1.0 ) 
//  { 
//    ret = (1.0*ret) + (2.0 * test);
//    ret=dp(ret,precision); 
//  }
//  //alert(ret);
//  return ret;
//} // End dp
//
////**********************************************************************
//function LotsOfSaturdays()
////**********************************************************************
//{
//  //alert("Here");
//  var n = new Array();
//  var d = new Date(); x=0;
//  while (d.getDay()!=6 && x < 7)
//  {
//    d = new Date(d.getTime()-86400000);
//    //alert (d.getDay()); x=x+1;
//  }
//  //alert("Here 2");
//  var x=0;
//  while (x<26)
//  {
//    d = new Date(d.getTime() + (7*86400000));
//    n[x] = d.getDate() + "-" + eval(d.getMonth()+1) + "-" + d.getFullYear();
//    x=x+1;
//  }
//  //alert("Here 3");
//  return n; 
//} // LastSaturday
//
////**********************************************************************
//function cCalcPoints( home_away, rownum)
////**********************************************************************
//{
//  var err=true;
//  //alert("In cCalcPoints() " + home_away + " " + rownum);
//  var tot = 0;
//  var tmp = 0;
//  tmp = 1*eval("document.ResultsForm." + home_away + "resultpts" + rownum + ".value");
//  tot = tot + tmp;
//  tmp = 1*eval("document.ResultsForm." + home_away + "battingpts" + rownum + ".value");
//  if (tmp<0||tmp>gMaxBattingPoints) { alert("Batting points must be between 0 and " + gMaxBattingPoints); err=false; }
//  tot = tot + tmp;
//  tmp = 1*eval("document.ResultsForm." + home_away + "bowlingpts" + rownum + ".value");
//  if (tmp<0||tmp>gMaxBowlingPoints) { alert("Bowling points must be between 0 and " + gMaxBowlingPoints); err=false; }
//  tot = tot + tmp;
//  tmp = 1*eval("document.ResultsForm." + home_away + "penaltypts" + rownum + ".value");
//  if (tmp>0) { alert("Penalty points must 0 or less"); err=false; }
//  tot = tot + tmp;
//  //alert(tot);
//  if (err==true) { eval("document.ResultsForm." + home_away + "totalpts" + rownum + ".value=" + tot); }
//  return err;
//} // cCalcPoints
//
////**********************************************************************
//function cCheckOneWinner()
////**********************************************************************
//{
//  var x=0;
//  var more=1;
//  var ret=true; var homeindex; var awayindex; var playedindex;
//  var homename; var awayname; var awayplayedindex;
//  //alert("In cCheckOneWinner()");
//  while (eval("document.ResultsForm.home" + x) != null)
//  {
//    playedindex = eval("document.ResultsForm.homeplayed" + x + ".selectedIndex");
//    awayplayedindex = eval("document.ResultsForm.awayplayed" + x + ".selectedIndex");
//    homeindex = eval("document.ResultsForm.homeresult" + x + ".selectedIndex");
//    awayindex = eval("document.ResultsForm.awayresult" + x + ".selectedIndex");
//    homename = eval("document.ResultsForm.home" + x + ".value");
//    awayname = eval("document.ResultsForm.away" + x + ".value");
//    //if (playedindex != awayplayedindex)
//    //{
//    //  alert("Both teams must play or both not play. " + homename + " v " + awayname);
//    //  ret=false;
//    //} 
//    //alert(x + " " + playedindex + " " + homeindex + " " + awayindex);
//    if (playedindex==0)
//    {
//      if ((homeindex == 0 && awayindex != 1)||(homeindex==1 && awayindex !=0))
//      {
//        //alert("If one teams wins, the other must lose. " + homename + " v " + awayname);
//        //ret=false;
//      }
//      else if ((homeindex == 2 && awayindex != 2))
//      {
//        alert("If one teams ties, the other must tie as well. " + homename + " v " + awayname);
//        ret=false;
//      }
//      else if ((homeindex == 3 && awayindex != 3))
//      {
//        alert("If one team\'s match is abandoned, the other\'s must be as well. " + homename + " v " + awayname);
//        ret=false;
//      }
//    }
//    x=x+1;
//  }
//  //alert("Here");
//  return ret;  
//} // End cCheckOneWinner()
//
////**********************************************************************
//function cResultPoints( home_away, rownum)
////**********************************************************************
//{
//  var res;
//  //alert("cResultPoints " + home_away + " " + rownum + " " + gPointsForWin);
//  res = eval("document.ResultsForm." + home_away + "result" + rownum + ".selectedIndex");
//  //alert(res);
//  if (res==0)
//  { eval("document.ResultsForm." + home_away + "resultpts" + rownum + ".value=" + gPointsForWin); }
//  else if (res==1)
//  { eval("document.ResultsForm." + home_away + "resultpts" + rownum + ".value=" + gPointsForDefeat); }
//  else if (res==2)
//  { eval("document.ResultsForm." + home_away + "resultpts" + rownum + ".value=" + gPointsForTie); }
//  else if (res==3)
//  { eval("document.ResultsForm." + home_away + "resultpts" + rownum + ".value=" + gPointsForAbandoned); }
//  cCalcPoints(home_away, rownum);
//} // End cResultPoints()

// **************************************************
function find_system() {
// **************************************************

  // alert( "Look for system" );  
  var system = document.location.search;
    
  var start_pos = system.search( /system=/ ) + "system=".length;
  system = system.substr( start_pos );
   
  var end_pos = system.search( /\&/ );
  if ( end_pos < 0 ) {
    end_pos = system.length;
  }
  system = system.substr( 0, end_pos );
  return system;
  
}

// **************************************************
function set_up() {
// **************************************************

  // alert( "In set_up xyzz" );
  
  // alert( "set_up(): cgi_path = " + cgi_path );

  var system = find_system();
  
  if ( document.location.href.search( /results.htm/ ) >= 0 ) {
  
    var path = cgi_path + "/results_system.pl?system=" + system + "&page=menu";    
    var frame_id = document.getElementById( "f_menu" );
    frame_id.src = path;
    // alert( "Frame source set to " + path );
    
    var path = cgi_path + "/results_system.pl?system=" + system + "&page=blank";    
    var frame_id = document.getElementById( "f_detail" );
    frame_id.src = path;

  }
  else if ( document.location.href.search( /blank.htm/ ) >= 0 ) {
  }
}

window.onload = set_up;


