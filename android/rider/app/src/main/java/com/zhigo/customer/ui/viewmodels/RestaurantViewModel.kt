package com.zhigo.customer.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zhigo.customer.data.models.Restaurant
import com.zhigo.customer.data.repository.RestaurantRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class RestaurantViewModel @Inject constructor(
    private val restaurantRepository: RestaurantRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<RestaurantUiState>(RestaurantUiState.Loading)
    val uiState: StateFlow<RestaurantUiState> = _uiState.asStateFlow()

    init {
        loadRestaurants()
    }

    fun loadRestaurants(zone: String? = null, city: String? = null) {
        viewModelScope.launch {
            _uiState.value = RestaurantUiState.Loading
            
            val result = restaurantRepository.getRestaurants(
                status = "approved",
                zone = zone,
                city = city
            )
            
            _uiState.value = if (result.isSuccess) {
                val restaurants = result.getOrNull() ?: emptyList()
                if (restaurants.isEmpty()) {
                    RestaurantUiState.Empty
                } else {
                    RestaurantUiState.Success(restaurants)
                }
            } else {
                RestaurantUiState.Error(result.exceptionOrNull()?.message ?: "Failed to load restaurants")
            }
        }
    }

    fun retry() {
        loadRestaurants()
    }
}

sealed class RestaurantUiState {
    object Loading : RestaurantUiState()
    object Empty : RestaurantUiState()
    data class Success(val restaurants: List<Restaurant>) : RestaurantUiState()
    data class Error(val message: String) : RestaurantUiState()
}
