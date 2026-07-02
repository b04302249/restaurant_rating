package RestaurantRating.backend.controller;

import RestaurantRating.backend.entity.Restaurant;
import RestaurantRating.backend.service.RestaurantService;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;
import java.util.List;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequestMapping("/api/restaurants")
public class RestaurantController {
    private final RestaurantService restaurantService;

    public RestaurantController(RestaurantService restaurantService) {
        this.restaurantService = restaurantService;
    }

    @PostMapping
    public RestaurantResponse create(@RequestBody @Validated CreateRestaurantRequest request) {
        return toResponse(restaurantService.create(
                request.name(),
                request.area(),
                request.category(),
                request.address(),
                request.note()
        ));
    }

    @GetMapping
    public List<RestaurantResponse> findAll() {
        return restaurantService.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @GetMapping("/{id}")
    public RestaurantResponse findById(@PathVariable Long id) {
        return toResponse(restaurantService.findById(id));
    }

    private RestaurantResponse toResponse(Restaurant restaurant) {
        return new RestaurantResponse(
                restaurant.getId(),
                restaurant.getName(),
                restaurant.getArea(),
                restaurant.getCategory(),
                restaurant.getAddress(),
                restaurant.getNote(),
                restaurant.getCreatedAt()
        );
    }

    public record CreateRestaurantRequest(
            @NotBlank String name,
            @NotBlank String area,
            @NotBlank String category,
            @NotBlank String address,
            String note
    ) {
    }

    public record RestaurantResponse(
            Long id,
            String name,
            String area,
            String category,
            String address,
            String note,
            Instant createdAt
    ) {
    }
}
