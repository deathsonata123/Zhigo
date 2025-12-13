package com.zhigo.customer.data.repository

import com.zhigo.customer.data.api.ApiService
import com.zhigo.customer.data.models.Restaurant
import com.zhigo.customer.data.models.MenuItem
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class RestaurantRepository @Inject constructor(
    private val apiService: ApiService
) {

    suspend fun getRestaurants(
        status: String? = "approved",
        zone: String? = null,
        city: String? = null
    ): Result<List<Restaurant>> {
        return try {
            val response = apiService.getRestaurants(status, zone, city)
            
            if (response.isSuccessful && response.body()?.success == true) {
                Result.success(response.body()!!.data ?: emptyList())
            } else {
                Result.failure(Exception(response.body()?.error ?: "Failed to fetch restaurants"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getRestaurant(id: String): Result<Restaurant> {
        return try {
            val response = apiService.getRestaurant(id)
            
            if (response.isSuccessful && response.body()?.success == true) {
                Result.success(response.body()!!.data!!)
            } else {
                Result.failure(Exception(response.body()?.error ?: "Restaurant not found"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun getMenuItems(restaurantId: String): Result<List<MenuItem>> {
        return try {
            val response = apiService.getMenuItems(restaurantId)
            
            if (response.isSuccessful && response.body()?.success == true) {
                Result.success(response.body()!!.data ?: emptyList())
            } else {
                Result.failure(Exception(response.body()?.error ?: "Failed to fetch menu"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
