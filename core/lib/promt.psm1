Using namespace System.Net

Set-StrictMode -Version Latest

class Promt {
  [int]$Port = 3000;
  [string]$BaseURL = '';
  [string]$Host = 'http://localhost';
  [string]$Url;
  [string]$PublicURL = './public';
  [HttpListener]$Http = (New-Object HttpListener);
  [System.Collections.ArrayList]$Handles = @();

  # Ctor implementations
  Promt([int]$port, [string]$baseURL, [string]$_host, [string]$publicURL) {
    $this.Port = $port;
    $this.Host = $_host;
    $this.BaseURL = $baseURL;
    $this.PublicURL = $publicURL
    $this._Init();
  }

  Promt([int]$port, [string]$baseURL, [string]$_host) {
    $this.Port = $port;
    $this.Host = $_host;
    $this.BaseURL = $baseURL;
    $this._Init();
  }

  Promt([int]$port) {
    $this.Port = $port;
    $this._Init();
  }

  Promt([string]$baseURL) {
    $this.BaseURL = $baseURL;
    $this._Init();
  }

  Promt() {
    $this._Init();
  }

  [void] _Init() {
    $this._WriteOutput("Promt init", "green")
    $this._SetURL();
  }

  [void] _SetURL() {
    [string]$this.URL = "$($this.Host):$($this.Port)/$($this.BaseURL)";
  }

  [void] _OpenWebApplication() {
    $indexFile = "$($this.PublicURL)/index.html";

    if (( Test-Path -Path $indexFile)) {
      $this._WriteOutput("Starting web application from $indexFile", "Green");
      . $indexFile;
    }
  }

  [void] Start() {
    $this._WriteOutput("Starting Promt HTTP server...", "Green");
    $this.Http = New-Object HttpListener;
    $this.Http.Start();

    # Apply default handles
    function defaultRequestHandle() {
      return $this.Handles
    }

    function exitRequestHandle() {
      $this.Stop();
      exit;
    }

    $this.Add('', $function:defaultRequestHandle);
    $this.Add('exit', $function:exitRequestHandle);

    $this.Http.Prefixes.Add($this.URL);
    $this.Http.AuthenticationSchemes = [AuthenticationSchemes]::Anonymous;

    $this._WriteOutput("Default request handler in accessible at:", "Green");
    $this._WriteOutput($this.URL, "Cyan");

    # Open webpage if one exists
    $this._OpenWebApplication();
    
    while ($this.Http.IsListening) {
      # Get incoming request
      $context = $this.Http.GetContext();
      $request = $context.Request;
      $response = $context.Response;

      # Set cors headers
      $response.AddHeader("Access-Control-Allow-Origin", "*");
      $response.AddHeader("Access-Control-Allow-Methods", "GET, POST, PATCH, PUT, DELETE, OPTIONS");
      $response.AddHeader("Access-Control-Allow-Headers", "Origin, Content-Type") ;

      $this._HandleRequest($request, $response);
    }

    $this.Stop();
  }

  [ScriptBlock] _GetHandle([string]$method, [URI]$url) {
    # Get matching request handle for url + method
    $handle = $this.Handles | ? { ($_.Method -eq $method -or $_.Method -eq '*') -and $_.Url.AbsolutePath -eq $url.AbsolutePath }
    
    if ($handle) {
      return $handle.Handle
    }
    else {
      throw "The handle for url: $url was not found"
    }
  }

  [void] _HandleRequest([HttpListenerRequest]$req, [HttpListenerResponse]$res) {
    $method = $req.HttpMethod;
    
    # Handle cors options request
    if ($method -eq "OPTIONS") {
      $res.Close();

      return;
    }

    try {
      $handle = $this._GetHandle($method, $req.URL);

      $res.StatusCode = 200;
      $res.ContentType = 'application/json';

      # Invoke request handler
      $this._WriteOutput("Invoking handle for [$method] $($req.URL)", "yellow");	
      $data = $handle.Invoke($req, $res);
        
      # Handle empty return
      if (!$data) {
        $data = "";
      }

      # Handle exit
      if ($req.URL.AbsolutePath -eq '/exit') { return; }

      # Sned back result stream returned by the handle
      $stream = $this._ToStream($data);
      $res.ContentLength64 = $stream.Length;
      try {
        $res.OutputStream.Write($stream, 0, $stream.Length);
      }
      catch {
        Write-Error $_
      }
    }
    catch {
      $err = $this._ToStream(@{Error = $_ });

      $res.StatusCode = 500;
      $res.ContentLength64 = $err.Length;
      try {
        $res.OutputStream.Write($err, 0, $err.Length);
      }
      catch {
        Write-Error $_
      }
    }
    finally {
      try {
        $res.Close();
      }
      catch {}
    }
  }

  [void] Stop() {
    $this._WriteOutput("Stopping Promt HTTP server", "Yellow");
    $this.Http.Stop();
    $this.Http.Dispose();
    $this._WriteOutput("Stopped", "Red");
  }

  [Byte[]] _ToStream([System.Management.Automation.PSObject]$obj) {
    if ($obj.GetType() -eq "String") {
      return [System.Text.Encoding]::UTF8.GetBytes(($obj));
    }
    else {
      return [System.Text.Encoding]::UTF8.GetBytes(($obj | ConvertTo-Json));
    }
  }

  [object] ParseJsonBody([System.Net.HttpListenerRequest]$req) {
    if (!$req.HasEntityBody) {
      throw "No body was provided with the request";
    }
  

    $body = $req.InputStream;
    $encoding = $req.ContentEncoding;
    $reader = [System.IO.StreamReader]::new($body, $encoding);

    $s = $reader.ReadToEnd();
    $data = $s | ConvertFrom-Json;

    $body.Close();
    $reader.Close();

    return $data
  }
 
  [void] Add([string]$url, [ScriptBlock]$requestHande) {
    $this._AddHandle("*", $url, $requestHande);
  }

  [void] Get([string]$url, [ScriptBlock]$requestHande) {
    $this._AddHandle("GET", $url, $requestHande);
  }

  [void] Post([string]$url, [ScriptBlock]$requestHande) {
    $this._AddHandle("POST", $url, $requestHande);
  }

  [void] Delete([string]$url, [ScriptBlock]$requestHande) {
    $this._AddHandle("DELETE", $url, $requestHande);
  }

  [void] Put([string]$url, [ScriptBlock]$requestHande) {
    $this._AddHandle("PUT", $url, $requestHande);
  }

  [void] Patch([string]$url, [ScriptBlock]$requestHande) {
    $this._AddHandle("PATCH", $url, $requestHande);
  }

  [void] _AddHandle([string]$method, [string]$url, [ScriptBlock]$requestHande) {
    $uri = [URI]::new($this.URL + $url);
    $this._WriteOutput("Mounting request handler for [$method] $uri", "Green");

    $this.Handles.Add(    
      [PSCustomObject]@{
        Method = $method;
        Handle = $requestHande;
        URL    = $uri
      }
    );
  }

  [void] _WriteOutput([string]$message, [string]$color) {
    Write-Host -Object "[$(Get-Date -Format "hh:MM:ss")] $message" -ForegroundColor $color
  }
   
}