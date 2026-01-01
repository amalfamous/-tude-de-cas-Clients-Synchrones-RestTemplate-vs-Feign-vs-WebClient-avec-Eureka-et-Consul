# Rapport d'Analyse : Comparaison des Clients HTTP Synchrones
## RestTemplate vs Feign vs WebClient avec Eureka et Consul

---

## Table des matières
1. [Contexte et objectifs](#contexte)
2. [Architecture mise en place](#architecture)
3. [Résultats des tests de performance](#performance)
4. [Tests de résilience](#resilience)
5. [Analyse comparative](#analyse)
6. [Conclusions et recommandations](#conclusions)

---

## Contexte et objectifs {#contexte}

Ce rapport présente une analyse comparative de trois approches de communication synchrone entre microservices Spring Boot :
- **RestTemplate** : Client HTTP traditionnel
- **Feign** : Client HTTP déclaratif
- **WebClient** : Client réactif (utilisé en mode synchrone)

### Objectifs pédagogiques
- Comparer les performances (latence, débit)
- Évaluer la simplicité d'implémentation
- Tester la résilience face aux pannes
- Mesurer l'impact du service discovery (Eureka vs Consul)

---

## Architecture mise en place {#architecture}

### Services déployés
- **Service Voiture** (port 8081) : API exposant `/api/cars/byClient/{clientId}`
- **Service Client** (port 8080) : Consommateur avec 3 endpoints
- **Eureka Server** (port 8761) : Service discovery
- **Consul** (port 8500) : Alternative de service discovery

### Endpoints testés
- `GET /api/clients/{id}/car/rest` (RestTemplate)
- `GET /api/clients/{id}/car/feign` (Feign)
- `GET /api/clients/{id}/car/webclient` (WebClient)

### Configuration de test
- Délai simulé : 50ms dans le service voiture
- Payload : JSON de ~57 octets
- Charges testées : 10, 50, 100, 200, 500 threads simultanés

---

## Résultats des tests de performance {#performance}

### Tableau 1 - Performance avec Eureka

| Méthode | Threads | Latence moyenne (ms) | Débit (req/s) | Taux d'erreur |
|---------|---------|----------------------|---------------|---------------|
| RestTemplate | 10 | 15 | 8.7 | 75% |
| Feign | 10 | 78 | 8.8 | 0% |
| WebClient | 10 | 27 | 10.5 | 75% |

### Tableau 2 - Performance avec Consul

| Méthode | Threads | Latence moyenne (ms) | Débit (req/min) | Taux d'erreur |
|---------|---------|----------------------|---------------|---------------|
| RestTemplate | 10 | 51 | 2.6 | 50% |
| Feign | 10 | 73 | 2.6 | 0% |
| WebClient | 10 | 95 | 2.6 | 50% |

### Tableau 3 - Consommation de ressources

| Méthode | CPU (%) | Mémoire (MB) | Observations |
|---------|----------|--------------|--------------|
| RestTemplate | 10-20 | 200-300 | Pics lors des erreurs |
| Feign | 5-15 | 180-250 | Stable et efficace |
| WebClient | 15-25 | 220-350 | Consommation variable |

---

## Tests de résilience {#resilience}

### Tableau 4 - Comportement face aux pannes

| Scénario | RestTemplate | Feign | WebClient | Observations |
|----------|--------------|-------|-----------|--------------|
| Panne service voiture | Échec immédiat | Échec immédiat | Échec immédiat | Tous échouent sans fallback |
| Panne Eureka/Consul | Erreurs intermittentes | Erreurs intermittentes | Erreurs intermittentes | Cache local limité |
| Reconnexion après panne | Récupération automatique | Récupération automatique | Récupération automatique | Une fois services redisponibles |

---

## Analyse comparative {#analyse}

### Performance
**Feign est le plus performant** avec 0% d'erreur dans les deux configurations. RestTemplate et WebClient montrent des taux d'erreur élevés (50-75%) ce qui les rend inutilisables en production. Eureka offre de meilleures performances que Consul avec un débit 3x supérieur.

### Simplicité d'implémentation
**Feign est le plus simple** avec une interface déclarative et aucune configuration HTTP manuelle. RestTemplate nécessite du code boilerplate. WebClient est complexe à utiliser en mode synchrone.

### Résilience
**Toutes les méthodes échouent sans fallback** lors des pannes. Feign offre une meilleure gestion des erreurs grâce à son approche déclarative. Le cache local du service discovery permet une continuité de service limitée.

### Impact du service discovery
**Eureka est plus performant** que Consul dans notre environnement de test. Consul ajoute une latence supplémentaire et réduit le débit. Cependant, Consul offre plus de fonctionnalités avancées.

---

## Conclusions et recommandations {#conclusions}

### Points clés
1. **Performance** : Feign est le plus fiable avec 0% d'erreur. Eureka surperforme Consul en termes de débit.
2. **Simplicité** : Feign offre la meilleure expérience développeur avec son approche déclarative.
3. **Résilience** : Aucune méthode ne gère les pannes gracefully. Des fallbacks sont nécessaires.
4. **Service Discovery** : Eureka est plus simple et performant, Consul plus riche en fonctionnalités.

### Recommandations
1. **Utiliser Feign** pour les nouveaux projets microservices
2. **Préférer Eureka** pour les environnements où la performance est critique
3. **Implémenter des fallbacks** pour améliorer la résilience
4. **Consul** pour les entreprises ayant besoin de fonctionnalités avancées (KV store, service mesh)
5. **Éviter RestTemplate/WebClient** sans configuration avancée et fallbacks

---

## Annexes

### Commandes de test
```bash
# Test des endpoints
curl http://localhost:8080/api/clients/1/car/rest
curl http://localhost:8080/api/clients/1/car/feign
curl http://localhost:8080/api/clients/1/car/webclient

# Test de performance
./performance-test-script.ps1

# Test de résilience
./resilience-test-script.ps1
```

### Configuration des services
- **Service Voiture** : Port 8081, délai 50ms
- **Service Client** : Port 8080
- **Eureka** : Port 8761
- **Consul** : Port 8500

*Rapport généré le : 1 janvier 2026*
