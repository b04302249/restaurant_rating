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
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class RatingService {
    private final RatingRepository ratingRepository;
    private final RestaurantRepository restaurantRepository;
    private final UserRepository userRepository;
    private final EventRepository eventRepository;

    public RatingService(
            RatingRepository ratingRepository,
            RestaurantRepository restaurantRepository,
            UserRepository userRepository,
            EventRepository eventRepository
    ) {
        this.ratingRepository = ratingRepository;
        this.restaurantRepository = restaurantRepository;
        this.userRepository = userRepository;
        this.eventRepository = eventRepository;
    }

    public Rating create(
            Long restaurantId,
            Long userId,
            Long eventId,
            short score,
            String comment,
            LocalDate visitedAt
    ) {
        Restaurant restaurant = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Restaurant not found: " + restaurantId));
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found: " + userId));

        Event event = null;
        if (eventId != null) {
            event = eventRepository.findById(eventId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Event not found: " + eventId));
        }

        Rating rating = new Rating();
        rating.setRestaurant(restaurant);
        rating.setUser(user);
        rating.setEvent(event);
        rating.setScore(score);
        rating.setComment(comment);
        rating.setVisitedAt(visitedAt);
        return ratingRepository.save(rating);
    }

    public List<Rating> findAll() {
        return ratingRepository.findAll();
    }

    public List<Rating> findByRestaurantId(Long restaurantId) {
        return ratingRepository.findByRestaurantId(restaurantId);
    }

    public Rating findById(Long id) {
        return ratingRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Rating not found: " + id));
    }
}
