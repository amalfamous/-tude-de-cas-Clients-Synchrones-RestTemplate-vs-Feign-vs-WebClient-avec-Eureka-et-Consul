# Guide d'Exécution des Tests

## 🚀 Démarrage rapide

### 1. Lancer les services avec Eureka
```bash
# Terminal 1 - Service Voiture (Eureka)
cd service-voiture
mvn spring-boot:run -Dspring-boot.run.profiles=eureka

# Terminal 2 - Service Client (Eureka)
cd service-client
mvn spring-boot:run -Dspring-boot.run.profiles=eureka

# Terminal 3 - Eureka Server (si pas déjà lancé)
cd eureka-server
mvn spring-boot:run
```

### 2. Lancer les services avec Consul
```bash
# Terminal 1 - Service Voiture (Consul)
cd service-voiture
mvn spring-boot:run -Dspring-boot.run.profiles=consul

# Terminal 2 - Service Client (Consul)
cd service-client
mvn spring-boot:run -Dspring-boot.run.profiles=consul

# Assurez-vous que Consul est lancé (port 8500)
```

## 🧪 Tests de validation

### Vérifier que les services fonctionnent
```powershell
# Test service voiture
Invoke-WebRequest -Uri "http://localhost:8081/api/cars/byClient/1" -Method GET

# Test service client - RestTemplate
Invoke-WebRequest -Uri "http://localhost:8080/api/clients/1/car/rest" -Method GET

# Test service client - Feign
Invoke-WebRequest -Uri "http://localhost:8080/api/clients/1/car/feign" -Method GET

# Test service client - WebClient
Invoke-WebRequest -Uri "http://localhost:8080/api/clients/1/car/webclient" -Method GET
```

## 📊 Tests de performance

### Option 1 - Script PowerShell (recommandé)
```powershell
# Exécuter le script de test de performance
.\performance-test-script.ps1

# Personnaliser les paramètres
.\performance-test-script.ps1 -BaseUrl "http://localhost:8080" -Threads @(10,50,100,200,500) -Duration 30
```

### Option 2 - JMeter
1. Ouvrir le fichier `test_plan.jmx` dans JMeter
2. Configurer les endpoints :
   - `http://localhost:8080/api/clients/1/car/rest`
   - `http://localhost:8080/api/clients/1/car/feign`
   - `http://localhost:8080/api/clients/1/car/webclient`
3. Configurer les charges : 10, 50, 100, 200, 500 utilisateurs
4. Lancer les tests et exporter les résultats

## 🔧 Tests de résilience

### Script de test de résilience
```powershell
# Exécuter le script (suit les instructions interactives)
.\resilience-test-script.ps1
```

### Tests manuels
1. **Panne service voiture** :
   - Arrêter le service voiture (port 8081)
   - Tester les endpoints client
   - Observer les timeouts/erreurs
   - Redémarrer le service voiture
   - Vérifier la récupération

2. **Panne service discovery** :
   - Arrêter Eureka (8761) ou Consul (8500)
   - Tester si les appels continuent (cache local)
   - Redémarrer le service discovery
   - Vérifier la réinscription

## 📈 Collecte des métriques

### Monitoring simple (Task Manager)
- Surveiller les processus Java des services
- Noter CPU% et RAM pendant les tests

### Monitoring avancé (Actuator + Prometheus)
```bash
# Actuator endpoints disponibles
http://localhost:8080/actuator/health
http://localhost:8080/actuator/metrics
http://localhost:8080/actuator/info
```

## 📋 Remplissage du rapport

### Tableaux à compléter dans `rapport-analyse.md`

1. **Performance** : Utiliser les résultats des scripts de test
2. **Résilience** : Utiliser les résultats des tests de panne
3. **CPU/Mémoire** : Utiliser les données du monitoring
4. **Analyse** : Comparer les trois approches

### Points d'analyse à aborder
- Quelle méthode donne la meilleure latence ?
- Quel est le débit maximal observé ?
- Quelle méthode est la plus simple à maintenir ?
- Impact du service discovery sur les performances ?
- Comportement face aux pannes ?

## 🎯 Objectifs du TP

✅ Implémenter deux microservices communicant synchroniquement  
✅ Configurer Eureka et Consul pour la découverte de services  
✅ Comparer RestTemplate, Feign et WebClient  
✅ Réaliser des tests de performance et collecter des métriques  
✅ Tester la résilience face aux pannes  
✅ Analyser et comparer les résultats

### Logs utiles
- Service voiture : `http://localhost:8081/actuator/health`
- Service client : `http://localhost:8080/actuator/health`
- Eureka UI : `http://localhost:8761`
- Consul UI : `http://localhost:8500`


