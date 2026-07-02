package RestaurantRating.backend.controller;

import RestaurantRating.backend.entity.Rating;
import RestaurantRating.backend.service.RatingService;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
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
@RequestMapping("/api/ratings")
public class RatingController {
    private final RatingService ratingService;

    public RatingController(RatingService ratingService) {
        this.ratingService = ratingService;
    }

    @PostMapping
    public RatingResponse create(@RequestBody @Validated CreateRatingRequest request) {
        return toResponse(ratingService.create(
                request.restaurantId(),
                request.userId(),
                request.eventId(),
                request.score(),
                request.comment(),
                request.visitedAt()
        ));
    }

    @GetMapping
    public List<RatingResponse> findAll() {
        return ratingService.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @GetMapping("/{id}")
    public RatingResponse findById(@PathVariable Long id) {
        return toResponse(ratingService.findById(id));
    }

    private RatingResponse toResponse(Rating rating) {
        return new RatingResponse(
                rating.getId(),
                rating.getRestaurant().getId(),
                rating.getUser() == null ? null : rating.getUser().getId(),
                rating.getEvent() == null ? null : rating.getEvent().getId(),
                rating.getScore(),
                rating.getComment(),
                rating.getVisitedAt(),
                rating.getCreatedAt()
        );
    }

    public record CreateRatingRequest(
            @NotNull Long restaurantId,
            @NotNull Long userId,
            Long eventId,
            @NotNull @Min(1) @Max(5) Short score,
            String comment,
            LocalDate visitedAt
    ) {
    }

    public record RatingResponse(
            Long id,
            Long restaurantId,
            Long userId,
            Long eventId,
            Short score,
            String comment,
            LocalDate visitedAt,
            Instant createdAt
    ) {
    }
}
