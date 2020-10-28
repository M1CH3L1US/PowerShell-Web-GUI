Using namespace System.Net

Set-StrictMode -Version Latest

class Promt {
  [int]$Port = 3000;
  [string]$BaseURL = '';
  [string]$Host = 'http://localhost';
  [string]$Url;
  [HttpListener]$Http = (New-Object HttpListener);
  [System.Collections.ArrayList]$Handles = @();

  Promt([int]$port, [string]$baseURL) {
    $this.Port = $port;
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
    $this._SetURL();
  }

  [void] _SetURL() {
    [string]$this.URL = "$($this.Host):$($this.Port)/$($this.BaseURL)";
  }

  [void] Start() {
    $this.Http = New-Object HttpListener;
    $this.Http.Start();

    function defaultRequestHandle() {
      return 'Welcome!'
    }

    $this.Add('', $function:defaultRequestHandle);

    $this.Http.Prefixes.Add($this.URL);
    $this.Http.AuthenticationSchemes = [AuthenticationSchemes]::Anonymous;

    while ($this.Http.IsListening) {
      $context = $this.Http.GetContext();
      $request = $context.Request;
      $response = $context.Response;
      $response.AddHeader("Access-Control-Allow-Origin", "*")

      $this.HandleRequest($request, $response);
    }

    $this.Stop();
  }

  [psobject] GetHandle([string]$method, [string]$url) {
    $uri = $url.replace($this.URL, '');
    $handle = $this.Handles | ? { ($_.Method -eq $method -or $_.Method -eq '*') -and $_.Url -eq $url }
    
    if ($handle) {
      return $handle.Handle
    }
    else {
      throw "The handle for url: $url was not found"
    }
  }

  [void] HandleRequest([HttpListenerRequest]$req, [HttpListenerResponse]$res) {
    $method = $req.HttpMethod;

    try {
      $handle = $this.GetHandle($method, $req.URL);

      $res.StatusCode = 200;
      $data = Invoke-Command $handle -ArgumentList $req, $res;
      $stream = $this.ToStream($data);
      $res.ContentType = 'application/json';
      $res.ContentLength64 = $stream.Length;
      $res.OutputStream.Write($stream, 0, $stream.Length);
    }
    catch {
      $err = $this.ToStream(@{Error = $_ });

      $res.StatusCode = 500;
      $res.ContentType = "application/json";
      $res.ContentLength64 = $err.Length;
      $res.OutputStream.Write($err, 0, $err.Length);
    }
    finally {
      $res.Close();
    }
  }

  [void] Stop() {
    $this.Http.Stop();
    $this.Http.Dispose();
  }

  [Byte[]] ToStream([System.Management.Automation.PSObject]$obj) {
    if ($obj.GetType() -eq "System.String") {
      return [System.Text.Encoding]::UTF8.GetBytes(($obj));
    }
    else {
      return [System.Text.Encoding]::UTF8.GetBytes(($obj | ConvertTo-Json));
    }
  }
 
  [void] Add([string]$url, $requestHande) {
    $this.AddHandle("*", $url, $requestHande);
  }

  [void] Get([string]$url, $requestHande) {
    $this.AddHandle("GET", $url, $requestHande);
  }

  [void] Post([string]$url, $requestHande) {
    $this.AddHandle("POST", $url, $requestHande);
  }

  [void] AddHandle([string]$method, [string]$url, $requestHande) {
    Write-Host -Object "Registering request handler for $([URI]::new($this.URL + $url))" -ForegroundColor Green 

    $this.Handles.Add(    
      [PSCustomObject]@{
        Method = $method;
        Handle = $requestHande;
        URL    = [URI]::new($this.URL + $url);
      }
    );
  }
}