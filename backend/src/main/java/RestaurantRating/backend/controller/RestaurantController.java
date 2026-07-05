package RestaurantRating.backend.controller;

import RestaurantRating.backend.entity.Category;
import RestaurantRating.backend.entity.Rating;
import RestaurantRating.backend.entity.Restaurant;
import RestaurantRating.backend.repository.RatingRepository;
import RestaurantRating.backend.service.RestaurantService;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;
import java.time.LocalDate;
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
    private final RatingRepository ratingRepository;

    public RestaurantController(RestaurantService restaurantService, RatingRepository ratingRepository) {
        this.restaurantService = restaurantService;
        this.ratingRepository = ratingRepository;
    }

    @PostMapping
    public RestaurantResponse create(@RequestBody @Validated CreateRestaurantRequest request) {
        return toResponse(restaurantService.create(
                request.name(),
                request.area(),
                request.categories(),
                request.googleMapLink(),
                request.businessHours()
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
        List<RatingResponse> ratings = ratingRepository.findByRestaurantId(restaurant.getId()).stream()
                .map(this::toRatingResponse)
                .toList();
        return new RestaurantResponse(
                restaurant.getId(),
                restaurant.getName(),
                restaurant.getArea(),
                restaurant.getCategories(),
                restaurant.getGoogleMapLink(),
                restaurant.getBusinessHours(),
                ratings
        );
    }

    private RatingResponse toRatingResponse(Rating rating) {
        return new RatingResponse(
                rating.getId(),
                rating.getUser() == null ? null : rating.getUser().getId(),
                rating.getEvent() == null ? null : rating.getEvent().getId(),
                rating.getScore(),
                rating.getComment(),
                rating.getVisitedAt(),
                rating.getCreatedAt()
        );
    }

    public record CreateRestaurantRequest(
            @NotBlank String name,
            String area,
            List<Category> categories,
            String googleMapLink,
            String businessHours
    ) {
    }

    public record RestaurantResponse(
            Long id,
            String name,
            String area,
            List<Category> categories,
            String googleMapLink,
            String businessHours,
            List<RatingResponse> ratings
    ) {
    }

    public record RatingResponse(
            Long id,
            Long userId,
            Long eventId,
            Short score,
            String comment,
            LocalDate visitedAt,
            Instant createdAt
    ) {
    }
}
