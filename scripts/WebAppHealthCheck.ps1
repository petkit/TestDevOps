$url = $OctopusParameters["HealthCheckUrl"]
$maxRetries = 10  # Number of retries
$delayInSeconds = 5  # Delay between retries (in seconds)
$attempt = 0  # Initialize attempt counter

function Test-Endpoint {
    param(
        [string]$url
    )

    try {
        # Try to send the request to the URL
        $response = Invoke-WebRequest -Uri $url -Method Get -ErrorAction Stop -UseBasicParsing

        if ($response.StatusCode -eq 200) {
            Write-Output "Service is healthy."
            return $true  # Exit the loop with success
        } else {
            Write-Output "Service is not healthy. Status code: $($response.StatusCode)"
            return $false  # Service is not healthy, keep retrying
        }
    }
    catch {
        # Handle exceptions and return failure
        Write-Output "Error encountered while checking the service: $_"
        return $false
    }
}

# Retry loop
while ($attempt -lt $maxRetries) {
    $attempt++
    Write-Output "Attempt $attempt of $maxRetries : Testing service health at $url"

    $isHealthy = Test-Endpoint -url $urls

    if ($isHealthy) {
        # Exit if the service is healthy
        Write-Output "Service is healthy on attempt $attempt. Exiting."
        exit 0
    }

    # If service is not healthy, wait before retrying
    if ($attempt -lt $maxRetries) {
        Write-Output "Waiting for $delayInSeconds seconds before retrying..."
        Start-Sleep -Seconds $delayInSeconds
    }
}

# If we reach this point, all attempts failed
Write-Output "Service is not healthy after $maxRetries attempts. Failing."
exit 1  # Return failure
