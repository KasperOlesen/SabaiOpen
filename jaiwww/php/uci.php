<?php
 header('Content-type: text/ecmascript');
 
 function uciGet($q){
	$q($action);
		
 }

// Settings Functions
function lan($in){
  exec("uci $in network.lan.ipaddr");
  exec("uci $in network.lan.netmask");
  if ( $in == "set" ) {
	exec("uci commit");
	network(restart);
}

function dhcp($in){
  exec("uci $in network.lan.ipaddr");
  exec("uci $in network.lan.netmask");
  if ( $in == "set" ) {
	exec("uci commit");
	dhcp(restart);
}


// Service Functions
function network($in){
  exec("service network $in");
}

?>