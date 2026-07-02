package RestaurantRating.backend.repository;

import RestaurantRating.backend.entity.Rating;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RatingRepository extends JpaRepository<Rating, Long> {
    List<Rating> findByRestaurantId(Long restaurantId);
}
