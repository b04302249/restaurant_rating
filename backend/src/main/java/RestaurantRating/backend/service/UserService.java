package RestaurantRating.backend.service;

import RestaurantRating.backend.entity.Restaurant;
import RestaurantRating.backend.entity.User;
import RestaurantRating.backend.repository.RestaurantRepository;
import RestaurantRating.backend.repository.UserRepository;
import java.util.List;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final RestaurantRepository restaurantRepository;

    public UserService(UserRepository userRepository, RestaurantRepository restaurantRepository) {
        this.userRepository = userRepository;
        this.restaurantRepository = restaurantRepository;
    }

    public User create(String name, String email) {
        User user = new User();
        user.setName(name);
        user.setEmail(email);
        return userRepository.save(user);
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public User findById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found: " + id));
    }

    @Transactional(readOnly = true)
    public List<Restaurant> getUserRestaurants(Long userId) {
        return List.copyOf(findById(userId).getRestaurants());
    }

    @Transactional
    public void addRestaurantToUser(Long userId, Long restaurantId) {
        User user = findById(userId);
        Restaurant restaurant = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Restaurant not found: " + restaurantId
                ));
        boolean alreadyAdded = user.getRestaurants().stream()
                .anyMatch(existing -> existing.getId().equals(restaurantId));
        if (!alreadyAdded) {
            user.getRestaurants().add(restaurant);
            userRepository.save(user);
        }
    }

    @Transactional
    public void removeRestaurantFromUser(Long userId, Long restaurantId) {
        User user = findById(userId);
        boolean removed = user.getRestaurants().removeIf(restaurant -> restaurant.getId().equals(restaurantId));
        if (removed) {
            userRepository.save(user);
        }
    }
}
