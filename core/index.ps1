Using module 'lib\promt.psm1';
Using namespace System.Net;

Set-StrictMode -Version Latest

function main {
  # Init Promt
  $promt = [Promt]::new();

  function GetTest([HttpListenerRequest]$req, [HttpListenerResponse]$res) {
    return @{ Test = "User" };
  }

  # Register handler for incoming requests
  $promt.Get("test", $function:GetTest);

  $promt.Start()
}

main;