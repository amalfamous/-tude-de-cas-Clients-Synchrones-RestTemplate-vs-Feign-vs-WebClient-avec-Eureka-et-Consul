package com.example.client;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.function.client.WebClient;

@RestController
public class ClientController {

    @Qualifier("directRestTemplate")
    private final RestTemplate restTemplate;
    
    private final CarFeignClient carFeignClient;
    
    @Qualifier("directWebClientBuilder")
    private final WebClient.Builder webClientBuilder;

    public ClientController(@Qualifier("directRestTemplate") RestTemplate restTemplate, 
                           CarFeignClient carFeignClient, 
                           @Qualifier("directWebClientBuilder") WebClient.Builder webClientBuilder) {
        this.restTemplate = restTemplate;
        this.carFeignClient = carFeignClient;
        this.webClientBuilder = webClientBuilder;
    }

    @GetMapping("/api/clients/{id}/car/rest")
    public Object getCarRest(@PathVariable Long id) {
        try {
            String url = "http://localhost:8081/api/cars/byClient/" + id;
            RestTemplate directTemplate = new RestTemplate();
            Object result = directTemplate.getForObject(url, Object.class);
            return result;
        } catch (Exception e) {
            return "RestTemplate Error: " + e.getClass().getSimpleName() + " - " + e.getMessage();
        }
    }

    @GetMapping("/api/clients/{id}/car/feign")
    public Object getCarFeign(@PathVariable Long id) {
        return carFeignClient.getCar(id);
    }

    @GetMapping("/api/clients/{id}/car/webclient")
    public Object getCarWebClient(@PathVariable Long id) {
        try {
            String url = "http://localhost:8081/api/cars/byClient/" + id;
            WebClient directClient = WebClient.builder().build();
            Object result = directClient
                    .get()
                    .uri(url)
                    .retrieve()
                    .bodyToMono(Object.class)
                    .block();
            return result;
        } catch (Exception e) {
            return "WebClient Error: " + e.getClass().getSimpleName() + " - " + e.getMessage();
        }
    }

    @GetMapping("/api/test")
    public String test() {
        return "Service client is working! Time: " + System.currentTimeMillis();
    }
}
