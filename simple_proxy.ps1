Add-Type -AssemblyName System.Net.Http

$tokenUrl = "https://external-api.domain.com"
$targetPort = <external-port>
$serverPort = <current-server-port>
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$serverPort/")
$listener.Start()
Write-Host "Proxy listening at Port $serverPort" -ForegroundColor Green

while ($true) {
    try {
        $context  = $listener.GetContext()
        $request  = $context.Request
        $response = $context.Response
        $method   = $request.HttpMethod
        $rawUrl   = $request.RawUrl
        $targetUrl = "{0}:{1}{2}" -f $tokenUrl, $serverPort, $rawUrl

        Write-Host "$method -> $targetUrl" -ForegroundColor Yellow

        #Method
        if ($method -eq "GET") {
            $hasBody = $false
        } else {
            $hasBody = $request.HasEntityBody
        }

        # Body
        $body = ""
        if ($hasBody) {
            $reader = New-Object System.IO.StreamReader($request.InputStream, $request.ContentEncoding)
            $body = $reader.ReadToEnd()
        }

        # Headers
        $headers = @{}
        foreach ($key in $request.Headers.AllKeys) {
            if ($key -notin @("Host", "Content-Length", "Connection", "Keep-Alive", "Proxy-Connection")) {
                $headers[$key] = $request.Headers[$key]
            }
        }

        # Invoke-WebRequest
        if ($method -eq "GET") {
            $result = Invoke-WebRequest -Uri $targetUrl -Method $method -Headers $headers -UseBasicParsing
        } else {
            if ($request.ContentType) {
            $result = Invoke-WebRequest -Uri $targetUrl -Method $method -Body $body -Headers $headers -UseBasicParsing -ContentType $request.ContentType -ErrorAction Stop
            } else {
                $result = Invoke-WebRequest -Uri $targetUrl -Method $method -Body $body -Headers $headers -UseBasicParsing
            }
        }

        $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($result.Content)
        $response.StatusCode = 200
        $response.ContentType = $result.Headers["Content-Type"]
        $response.ContentLength64 = $responseBytes.Length

        Write-Host "API Response: $($result.StatusCode) - $($responseBytes.Length)" -ForegroundColor Green
        $response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
    }
    catch {
        $errorText = "Error: $_"
        Write-Host $errorText -ForegroundColor Red
        $errorBytes = [System.Text.Encoding]::UTF8.GetBytes($errorText)
        $response.StatusCode = 500
        $response.ContentType = "text/plain"
        $response.ContentLength64 = $errorBytes.Length
        $response.OutputStream.Write($errorBytes, 0, $errorBytes.Length)
    }
    finally {
        $response.OutputStream.Close()
    }
}
