package RestaurantRating.backend.service;

import RestaurantRating.backend.entity.Category;
import RestaurantRating.backend.entity.Restaurant;
import RestaurantRating.backend.repository.RestaurantRepository;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class RestaurantService {
    private final RestaurantRepository restaurantRepository;

    public RestaurantService(RestaurantRepository restaurantRepository) {
        this.restaurantRepository = restaurantRepository;
    }

    public Restaurant create(String name, String area, List<Category> categories, String googleMapLink, String businessHours) {
        Restaurant restaurant = new Restaurant();
        restaurant.setName(name);
        restaurant.setArea(area);
        restaurant.setCategories(categories);
        restaurant.setGoogleMapLink(googleMapLink);
        restaurant.setBusinessHours(businessHours);
        return restaurantRepository.save(restaurant);
    }

    public List<Restaurant> findAll() {
        return restaurantRepository.findAll();
    }

    public Restaurant findById(Long id) {
        return restaurantRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Restaurant not found: " + id));
    }
}
