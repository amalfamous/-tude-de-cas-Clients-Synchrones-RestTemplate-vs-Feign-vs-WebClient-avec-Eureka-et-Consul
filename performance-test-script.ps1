# Script de test de performance pour les microservices
# Teste RestTemplate, Feign et WebClient avec différentes charges

param(
    [string]$BaseUrl = "http://localhost:8080",
    [int[]]$Threads = @(1, 2, 5, 10),
    [int]$Duration = 15
)

$endpoints = @(
    "/api/clients/1/car/rest",
    "/api/clients/1/car/feign", 
    "/api/clients/1/car/webclient"
)

$results = @()

foreach ($endpoint in $endpoints) {
    $method = if ($endpoint -like "*rest*") { "RestTemplate" }
              elseif ($endpoint -like "*feign*") { "Feign" }
              else { "WebClient" }
    
    Write-Host "Testing $method with endpoint: $endpoint"
    
    foreach ($threadCount in $Threads) {
        Write-Host "  Threads: $threadCount"
        
        $startTime = Get-Date
        $successCount = 0
        $errorCount = 0
        $totalTime = 0
        
        # Créer des tâches parallèles
        $jobs = @()
        for ($i = 0; $i -lt $threadCount; $i++) {
            $job = Start-Job -ScriptBlock {
                param($url, $duration)
                $count = 0
                $endTime = (Get-Date).AddSeconds($duration)
                
                while ((Get-Date) -lt $endTime) {
                    try {
                        $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10
                        $count++
                    } catch {
                        # Erreur ignorée pour le comptage
                    }
                }
                return $count
            } -ArgumentList "$BaseUrl$endpoint", $Duration
            
            $jobs += $job
        }
        
        # Attendre la fin de tous les jobs
        $jobs | Wait-Job | Out-Null
        
        # Collecter les résultats
        foreach ($job in $jobs) {
            $result = Receive-Job $job
            $successCount += $result
        }
        
        $jobs | Remove-Job
        
        $actualDuration = (Get-Date) - $startTime
        $throughput = [math]::Round($successCount / $actualDuration.TotalSeconds, 2)
        
        $results += [PSCustomObject]@{
            Method = $method
            Threads = $threadCount
            Duration = $actualDuration.TotalSeconds
            SuccessCount = $successCount
            Throughput = $throughput
            Endpoint = $endpoint
        }
    }
}

# Afficher les résultats
Write-Host "`n=== RÉSULTATS DES TESTS DE PERFORMANCE ==="
$results | Format-Table -AutoSize

# Exporter en CSV
$results | Export-Csv -Path "performance-results.csv" -NoTypeInformation
Write-Host "`nRésultats exportés dans performance-results.csv"
