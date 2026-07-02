package RestaurantRating.backend.repository;

import RestaurantRating.backend.entity.Rating;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RatingRepository extends JpaRepository<Rating, Long> {
}
