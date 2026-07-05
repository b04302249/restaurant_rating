package RestaurantRating.backend.service;

import RestaurantRating.backend.entity.Event;
import RestaurantRating.backend.entity.Rating;
import RestaurantRating.backend.entity.Restaurant;
import RestaurantRating.backend.entity.User;
import RestaurantRating.backend.repository.EventRepository;
import RestaurantRating.backend.repository.RatingRepository;
import RestaurantRating.backend.repository.RestaurantRepository;
import RestaurantRating.backend.repository.UserRepository;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class EventService {
    private final EventRepository eventRepository;
    private final RestaurantRepository restaurantRepository;
    private final UserRepository userRepository;
    private final RatingRepository ratingRepository;

    public EventService(
            EventRepository eventRepository,
            RestaurantRepository restaurantRepository,
            UserRepository userRepository,
            RatingRepository ratingRepository
    ) {
        this.eventRepository = eventRepository;
        this.restaurantRepository = restaurantRepository;
        this.userRepository = userRepository;
        this.ratingRepository = ratingRepository;
    }

    @Transactional
    public Event create(
            String title,
            LocalDate eventDate,
            Long restaurantId,
            List<Long> participantUserIds,
            List<Long> ratingIds
    ) {
        Restaurant restaurant = null;
        if (restaurantId != null) {
            restaurant = restaurantRepository.findById(restaurantId)
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.NOT_FOUND, "Restaurant not found: " + restaurantId));
        }

        List<Long> safeParticipantIds = participantUserIds == null ? Collections.emptyList() : participantUserIds;
        List<User> users = safeParticipantIds.isEmpty() ? Collections.emptyList() : userRepository.findAllById(safeParticipantIds);
        if (users.size() != safeParticipantIds.size()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Some participant users do not exist");
        }

        Event event = new Event();
        event.setTitle(title);
        event.setEventDate(eventDate);
        event.setRestaurant(restaurant);
        event.setUsers(users);
        Event saved = eventRepository.save(event);

        List<Long> safeRatingIds = ratingIds == null ? Collections.emptyList() : ratingIds;
        if (!safeRatingIds.isEmpty()) {
            List<Rating> ratings = ratingRepository.findAllById(safeRatingIds);
            if (ratings.size() != safeRatingIds.size()) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Some ratings do not exist");
            }

            for (Rating rating : ratings) {
                if (restaurantId != null && !rating.getRestaurant().getId().equals(restaurantId)) {
                    throw new ResponseStatusException(
                            HttpStatus.BAD_REQUEST, "Rating " + rating.getId() + " belongs to a different restaurant");
                }
                rating.setEvent(saved);
            }
            ratingRepository.saveAll(ratings);
        }

        return saved;
    }

    @Transactional(readOnly = true)
    public List<Event> findAll() {
        List<Event> events = eventRepository.findAll();
        events.forEach(event -> {
            event.getUsers().size();
            event.getRatings().size();
        });
        return events;
    }

    @Transactional(readOnly = true)
    public Event findById(Long id) {
        Event event = eventRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found: " + id));
        event.getUsers().size();
        event.getRatings().size();
        return event;
    }
}
