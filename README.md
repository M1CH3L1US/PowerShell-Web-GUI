# PowerShell Web UI

## PoweShell and user interfaces

If you are a Windows sysadmin you have probably worked with PowerShell before. This might have been for some automated task that is being run on a schedule or by another member of your team. You will eventually come to the point where you have to make a ui for a larger script when params won't cut it anymore or the end user is not tech savvy enough to handle it.

## Windows Forms to the rescue - Or maybe not

Having reached that dreadful point of having to build a UI for your script you'll most likely start having a look at something like Windows Forms. Even though there are great resources out there to get you up on track with Windows Forms it's still a drag to write these extensive form declarations. To make things easier there are online designers like [PoshGUI](https://poshgui.com/) which honestly work great even in the way of customisation. Still, if you aim to create a more extensive user experience in a reasonable amount of time this will most likely not do the trick.

# The Alternative - This Project

All the hate aside the alternative, depending on your needs, may be way overcomplicating the solution and you'd be better off just using something like Windows Forms!

## So what are we doing?

The premise of this project is to use HTTP calls to connect your PowerShell application with a UI written in HTML and JavaScript or some other web technology. You can use the framework of your choice or plain HTML as long as it supports some way of fetching data froma a http server. In this example I've included the base of an Angular application as I feel most comfortable with it.

## Setting up your files

The final build folder structure is going to look something like this

```
root
- index.ps1     // Entry point for your application
- lib           // This folder will contain all library files required by the PowerShell application
  - promt.psm1  // PowerShell web server
  - *.psm1      // Additional files
- public        // This folder will contain all the files needed for the UI
  - index.html  // Entry point for your web application - UI
  - *.*         // Additional files
```

Be sure to keep the naming of your files as specified.

## Getting started

In your `index.ps1` file import the `promt class` from the lib directory and instanciate a new instance. Be sure to check for configuration parameters if you don't want to use the default settings.

```PowerShell
Using module 'lib\promt.psm1';
Using namespace System.Net;

Set-StrictMode -Version Latest;

$promt = [Promt]::new();
```

Now it's time to work some magic. We're adding some endpoints to the promt webserver. We can do this by either specifying the HTTP method like `$promt.Get` or `$promt.Post` or just use any method `$promt.Add`. These methods take both a url and a funciton to handle the request as an argument. The function will then be called with the `Request` and `Response` object of the HTTP listener to have access to all data needed to handle the request.

```PowerShell
function GetADUser([HttpListenerRequest]$req, [HttpListenerResponse]$res) {
    # Get username from the querystring
    # HTTP request URL: http://localhost:3000/aduser?userprincipalname=test
    $userprincipalname = $req.QueryString["userprincipalname"];
    $adUser = Get-ADUser -Filter "userprincipalname -eq '$userprincipalname'";

    # Savely throw erros which are then sent to the client
    if(!$adUser) {
        throw "The user with the username $userprincipalname was not found";
    }

    # Return the value to be sent back to the client
    return $adUser;
}

# Register the handle
$promt.Get("aduser", $function:GetADUser);
```

Now you can use `$promt.Start()` to start your application. Promt will then automatically open the default browser if the public file exists. By default this is ./public/index.html and can be overwritten in the constructor.

### That's it

Welp that's basically all you need to know for creating a basic api for your web UI with PowerShell.

## Deployment

There is a node deployment script to use with the Angular template. To run it use `npm run deploy`. If it doesn't fit your need or you'd rather use your own platform that isn't Angular feel free to change the `deploy.ts` file and then recompile it to JavaScript using the TypeScript compiler (`tsc`).

# Promt HTTP server

A HTTP server built using the HTTPListener .NET class.

## Public methods

Private methods are prefixed with `_` e.g. `_init()`.

### Start()

> Starts the http server

### ParseJsonBody([HttpListenerRequest]\$req)

> Parses the body of a request from JSON to a PowerShell object

Takes the request object from a http request as its argument.

### Add([string]$url, $requestHande)

### Get([string]$url, $requestHande)

### Post([string]$url, $requestHande)

### Delete([string]$url, $requestHande)

### Put([string]$url, $requestHande)

### Patch([string]$url, $requestHande)

> Maps the request handle from the argument to the url.

## Constructor implementations

### Promt([int]$port, [string]$baseURL, [string]$_host, [string]$publicURL)

### Promt([int]$port, [string]$baseURL, [string]\$\_host)

### Promt([int]\$port)

### Promt()

## port

> The listening port

Default: 3000

## baseURL

> The base URL of the server ex. http://localhost:3000/`api/base`

Default: ""

## host

> The hostname of the server

Default: localhost

## publicURL

> The file URL to the folder of the web application

Defualt: ./public
