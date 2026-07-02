package RestaurantRating.backend.repository;

import RestaurantRating.backend.entity.Event;
import org.springframework.data.jpa.repository.JpaRepository;

public interface EventRepository extends JpaRepository<Event, Long> {
}
