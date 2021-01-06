Using module 'lib\promt.psm1';
Using namespace System.Net;

Set-StrictMode -Version Latest

function main {
  # Init Promt
  $promt = [Promt]::new();

  # Register handler for incoming requests
  $promt.Get("test", {
      param(
        [HttpListenerRequest]$req, 
        [HttpListenerResponse]$res
      );

      return @{ Test = "User" };
    });

  # Create a handler without mapping it
  $fooHandle = {
    param(
      [HttpListenerRequest]$req, 
      [HttpListenerResponse]$res
    );

    return @{ Bar = "Baz" };
  }

  # Map handler scriptblock
  $promt.Get("foo", $fooHandle);
  $promt.Start();
}

main;