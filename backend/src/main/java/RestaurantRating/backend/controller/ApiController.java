package RestaurantRating.backend.controller;

import java.util.Map;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class ApiController {
    @GetMapping("/ping")
    public Map<String, String> ping() {
        return Map.of("status", "ok");
    }

    @GetMapping("/routes")
    public Map<String, Object> routes() {
        return Map.of(
                "users", "/api/users",
                "restaurants", "/api/restaurants",
                "ratings", "/api/ratings",
                "events", "/api/events",
                "ping", "/api/ping",
                "health", "/actuator/health"
        );
    }
}
