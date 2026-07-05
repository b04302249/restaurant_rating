package RestaurantRating.backend.controller;

import RestaurantRating.backend.entity.Rating;
import RestaurantRating.backend.entity.Restaurant;
import RestaurantRating.backend.entity.User;
import RestaurantRating.backend.repository.RatingRepository;
import RestaurantRating.backend.service.UserService;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Validated
@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;
    private final RatingRepository ratingRepository;

    public UserController(UserService userService, RatingRepository ratingRepository) {
        this.userService = userService;
        this.ratingRepository = ratingRepository;
    }

    @PostMapping
    public UserResponse create(@RequestBody @Validated CreateUserRequest request) {
        return toResponse(userService.create(request.name(), request.email()));
    }

    @GetMapping
    public List<UserResponse> findAll() {
        return userService.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @GetMapping("/{id}")
    public UserResponse findById(@PathVariable Long id) {
        return toResponse(userService.findById(id));
    }

    @GetMapping("/{userId}/restaurants")
    public List<RestaurantController.RestaurantResponse> getUserRestaurants(@PathVariable Long userId) {
        return userService.getUserRestaurants(userId).stream()
                .map(this::toRestaurantResponse)
                .toList();
    }

    @PostMapping("/{userId}/restaurants/{restaurantId}")
    public void addRestaurant(@PathVariable Long userId, @PathVariable Long restaurantId) {
        userService.addRestaurantToUser(userId, restaurantId);
    }

    @DeleteMapping("/{userId}/restaurants/{restaurantId}")
    public void removeRestaurant(@PathVariable Long userId, @PathVariable Long restaurantId) {
        userService.removeRestaurantFromUser(userId, restaurantId);
    }

    private UserResponse toResponse(User user) {
        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getCreatedAt()
        );
    }

    private RestaurantController.RestaurantResponse toRestaurantResponse(Restaurant restaurant) {
        List<RestaurantController.RatingResponse> ratings = ratingRepository.findByRestaurantId(restaurant.getId())
                .stream()
                .map(this::toRatingResponse)
                .toList();
        return new RestaurantController.RestaurantResponse(
                restaurant.getId(),
                restaurant.getName(),
                restaurant.getArea(),
                restaurant.getCategories(),
                restaurant.getGoogleMapLink(),
                restaurant.getBusinessHours(),
                ratings
        );
    }

    private RestaurantController.RatingResponse toRatingResponse(Rating rating) {
        return new RestaurantController.RatingResponse(
                rating.getId(),
                rating.getUser() == null ? null : rating.getUser().getId(),
                rating.getEvent() == null ? null : rating.getEvent().getId(),
                rating.getScore(),
                rating.getComment(),
                rating.getVisitedAt(),
                rating.getCreatedAt()
        );
    }

    public record CreateUserRequest(
            @NotBlank String name,
            @NotBlank @Email String email
    ) {
    }

    public record UserResponse(
            Long id,
            String name,
            String email,
            Instant createdAt
    ) {
    }
}
