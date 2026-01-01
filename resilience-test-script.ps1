# Script de test de résilience pour les microservices
# Teste les scénarios de panne

param(
    [string]$ClientUrl = "http://localhost:8080",
    [string]$CarServiceUrl = "http://localhost:8081",
    [string]$EurekaUrl = "http://localhost:8761",
    [string]$ConsulUrl = "http://localhost:8500"
)

function Test-ServiceHealth {
    param([string]$Url, [string]$ServiceName)
    
    try {
        $response = Invoke-WebRequest -Uri "$Url/actuator/health" -Method GET -TimeoutSec 5
        return $true
    } catch {
        Write-Host "$ServiceName is not responding: $($_.Exception.Message)"
        return $false
    }
}

function Test-Endpoint {
    param([string]$Url, [string]$Endpoint)
    
    try {
        $startTime = Get-Date
        $response = Invoke-WebRequest -Uri "$Url$Endpoint" -Method GET -TimeoutSec 10
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalMilliseconds
        
        return @{
            Success = $true
            Duration = $duration
            StatusCode = $response.StatusCode
        }
    } catch {
        return @{
            Success = $false
            Duration = 0
            Error = $_.Exception.Message
        }
    }
}

Write-Host "=== TEST DE RÉSILIENCE DES MICROSERVICES ===`n"

# Test 1: Panne du service voiture
Write-Host "Test 1: Panne du service voiture"
Write-Host "Arrêtez manuellement le service voiture (port 8081) puis appuyez sur Entrée..."
Read-Host

$endpoints = @("/api/clients/1/car/rest", "/api/clients/1/car/feign", "/api/clients/1/car/webclient")
foreach ($endpoint in $endpoints) {
    $result = Test-Endpoint -Url $ClientUrl -Endpoint $endpoint
    $method = if ($endpoint -like "*rest*") { "RestTemplate" }
              elseif ($endpoint -like "*feign*") { "Feign" }
              else { "WebClient" }
    
    Write-Host "$method`: $($result.Success) - Durée: $($result.Duration)ms"
    if (-not $result.Success) {
        Write-Host "  Erreur: $($result.Error)"
    }
}

Write-Host "`nRedémarrez le service voiture puis appuyez sur Entrée..."
Read-Host

# Test 2: Vérification de la récupération
Write-Host "`nTest 2: Vérification de la récupération après redémarrage"
foreach ($endpoint in $endpoints) {
    $result = Test-Endpoint -Url $ClientUrl -Endpoint $endpoint
    $method = if ($endpoint -like "*rest*") { "RestTemplate" }
              elseif ($endpoint -like "*feign*") { "Feign" }
              else { "WebClient" }
    
    Write-Host "$method`: $($result.Success) - Durée: $($result.Duration)ms"
}

# Test 3: Panne du serveur de découverte
Write-Host "`nTest 3: Panne du serveur de découverte"
Write-Host "Arrêtez Eureka (port 8761) ou Consul (port 8500) puis appuyez sur Entrée..."
Read-Host

# Test si les services continuent de fonctionner avec le cache local
foreach ($endpoint in $endpoints) {
    $result = Test-Endpoint -Url $ClientUrl -Endpoint $endpoint
    $method = if ($endpoint -like "*rest*") { "RestTemplate" }
              elseif ($endpoint -like "*feign*") { "Feign" }
              else { "WebClient" }
    
    Write-Host "$method`: $($result.Success) - Durée: $($result.Duration)ms"
}

Write-Host "`nRedémarrez le serveur de découverte puis appuyez sur Entrée..."
Read-Host

# Test 4: Vérification finale
Write-Host "`nTest 4: Vérification finale après récupération complète"
foreach ($endpoint in $endpoints) {
    $result = Test-Endpoint -Url $ClientUrl -Endpoint $endpoint
    $method = if ($endpoint -like "*rest*") { "RestTemplate" }
              elseif ($endpoint -like "*feign*") { "Feign" }
              else { "WebClient" }
    
    Write-Host "$method`: $($result.Success) - Durée: $($result.Duration)ms"
}

Write-Host "`n=== TESTS DE RÉSILIENCE TERMINÉS ==="
