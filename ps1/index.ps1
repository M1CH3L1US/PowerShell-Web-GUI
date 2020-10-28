Using module 'lib\promt.ps1';
Using namespace System.Net;

$ps = [Promt]::new();

function fancy([System.Net.HttpListenerRequest]$req, [System.Net.HttpListenerResponse]$res) {
  return @{username = "Test" };
}

$ps.Get("stuff", $function:fancy)

$ps.Start()