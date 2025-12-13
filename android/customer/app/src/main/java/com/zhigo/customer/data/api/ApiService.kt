package com.zhigo.customer.data.api

import com.zhigo.customer.data.models.*
import retrofit2.Response
import retrofit2.http.*

interface ApiService {
    
    // ========================================
    // Authentication
    // ========================================
    
    @POST("api/auth/signin")
    suspend fun signIn(@Body request: SignInRequest): Response<ApiResponse<AuthTokens>>
    
    @POST("api/auth/signup")
    suspend fun signUp(@Body request: SignUpRequest): Response<ApiResponse<SignUpResponse>>
    
    @POST("api/auth/confirm")
    suspend fun confirmSignUp(@Body request: ConfirmRequest): Response<ApiResponse<String>>
    
    @POST("api/auth/signout")
    suspend fun signOut(@Header("Authorization") token: String): Response<ApiResponse<String>>
    
    @GET("api/auth/me")
    suspend fun getCurrentUser(@Header("Authorization") token: String): Response<ApiResponse<User>>
    
    // ========================================
    // Restaurants
    // ========================================
    
    @GET("api/restaurants")
    suspend fun getRestaurants(
        @Query("status") status: String? = null,
        @Query("zone") zone: String? = null,
        @Query("city") city: String? = null
    ): Response<ApiResponse<List<Restaurant>>>
    
    @GET("api/restaurants/{id}")
    suspend fun getRestaurant(@Path("id") id: String): Response<ApiResponse<Restaurant>>
    
    @GET("api/restaurants/{id}/menu")
    suspend fun getMenuItems(@Path("id") restaurantId: String): Response<ApiResponse<List<MenuItem>>>
    
    // ========================================
    // Orders
    // ========================================
    
    @GET("api/orders")
    suspend fun getOrders(
        @Header("Authorization") token: String,
        @Query("status") status: String? = null
    ): Response<ApiResponse<List<Order>>>
    
    @POST("api/orders")
    suspend fun createOrder(
        @Header("Authorization") token: String,
        @Body order: CreateOrderRequest
    ): Response<ApiResponse<Order>>
    
    @GET("api/orders/{id}")
    suspend fun getOrder(
        @Header("Authorization") token: String,
        @Path("id") id: String
    ): Response<ApiResponse<Order>>
    
    // ========================================
    // Storage
    // ========================================
    
    @POST("api/storage/upload-url")
    suspend fun getUploadUrl(
        @Header("Authorization") token: String,
        @Body request: UploadUrlRequest
    ): Response<ApiResponse<UploadUrlResponse>>
}

// Request/Response models
data class SignInRequest(
    val email: String,
    val password: String
)

data class SignUpRequest(
    val email: String,
    val password: String,
    val fullName: String,
    val phone: String? = null,
    val role: String? = null
)

data class ConfirmRequest(
    val email: String,
    val code: String
)

data class AuthTokens(
    val accessToken: String,
    val idToken: String,
    val refreshToken: String,
    val expiresIn: Int
)

data class SignUpResponse(
    val userSub: String,
    val userConfirmed: Boolean
)

data class CreateOrderRequest(
    val restaurant_id: String,
    val restaurant_name: String,
    val customer_name: String,
    val customer_phone: String,
    val customer_address: String,
    val delivery_zone: String,
    val items: List<OrderItem>,
    val subtotal: Double,
    val delivery_fee: Double,
    val service_fee: Double,
    val vat: Double,
    val tip: Double,
    val total: Double,
    val payment_method: String = "cod"
)

data class UploadUrlRequest(
    val fileName: String,
    val contentType: String,
    val folder: String
)

data class UploadUrlResponse(
    val uploadUrl: String,
    val key: String
)

data class ApiResponse<T>(
    val success: Boolean,
    val data: T?,
    val error: String? = null,
    val message: String? = null
)
