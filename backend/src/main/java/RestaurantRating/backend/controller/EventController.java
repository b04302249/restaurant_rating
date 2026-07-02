package RestaurantRating.backend.controller;

import RestaurantRating.backend.entity.Event;
import RestaurantRating.backend.service.EventService;
import jakarta.validation.constraints.NotBlank;
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
@RequestMapping("/api/events")
public class EventController {
    private final EventService eventService;

    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    @PostMapping
    public EventResponse create(@RequestBody @Validated CreateEventRequest request) {
        return toResponse(eventService.create(
                request.title(),
                request.eventDate(),
                request.restaurantId(),
                request.participantUserIds(),
                request.ratingIds()
        ));
    }

    @GetMapping
    public List<EventResponse> findAll() {
        return eventService.findAll().stream()
                .map(this::toResponse)
                .toList();
    }

    @GetMapping("/{id}")
    public EventResponse findById(@PathVariable Long id) {
        return toResponse(eventService.findById(id));
    }

    private EventResponse toResponse(Event event) {
        return new EventResponse(
                event.getId(),
                event.getTitle(),
                event.getEventDate(),
                event.getRestaurant().getId(),
                event.getUsers().stream().map(user -> user.getId()).toList(),
                event.getRatings().stream().map(rating -> rating.getId()).toList(),
                event.getCreatedAt()
        );
    }

    public record CreateEventRequest(
            @NotBlank String title,
            @NotNull LocalDate eventDate,
            @NotNull Long restaurantId,
            List<Long> participantUserIds,
            List<Long> ratingIds
    ) {
    }

    public record EventResponse(
            Long id,
            String title,
            LocalDate eventDate,
            Long restaurantId,
            List<Long> participantUserIds,
            List<Long> ratingIds,
            Instant createdAt
    ) {
    }
}
