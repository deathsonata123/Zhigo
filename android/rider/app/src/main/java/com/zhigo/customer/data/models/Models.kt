package com.zhigo.customer.data.models

import com.google.gson.annotations.SerializedName

data class Restaurant(
    @SerializedName("id")
    val id: String,
    
    @SerializedName("name")
    val name: String,
    
    @SerializedName("email")
    val email: String,
    
    @SerializedName("phone")
    val phone: String,
    
    @SerializedName("address")
    val address: String,
    
    @SerializedName("photo_url")
    val photoUrl: String?,
    
    @SerializedName("zone")
    val zone: String,
    
    @SerializedName("city")
    val city: String,
    
    @SerializedName("latitude")
    val latitude: Double?,
    
    @SerializedName("longitude")
    val longitude: Double?,
    
    @SerializedName("status")
    val status: String = "pending",
    
    @SerializedName("pricing_plan")
    val pricingPlan: String = "commission",
    
    @SerializedName("created_at")
    val createdAt: String?
)

data class MenuItem(
    @SerializedName("id")
    val id: String,
    
    @SerializedName("restaurant_id")
    val restaurantId: String,
    
    @SerializedName("name")
    val name: String,
    
    @SerializedName("description")
    val description: String?,
    
    @SerializedName("price")
    val price: Double,
    
    @SerializedName("category")
    val category: String,
    
    @SerializedName("image_url")
    val imageUrl: String?,
    
    @SerializedName("is_available")
    val isAvailable: Boolean = true,
    
    @SerializedName("preparation_time")
    val preparationTime: Int?
)

data class Order(
    @SerializedName("id")
    val id: String,
    
    @SerializedName("restaurant_id")
    val restaurantId: String,
    
    @SerializedName("restaurant_name")
    val restaurantName: String,
    
    @SerializedName("customer_name")
    val customerName: String,
    
    @SerializedName("customer_phone")
    val customerPhone: String,
    
    @SerializedName("customer_address")
    val customerAddress: String,
    
    @SerializedName("delivery_zone")
    val deliveryZone: String,
    
    @SerializedName("items")
    val items: List<OrderItem>,
    
    @SerializedName("subtotal")
    val subtotal: Double,
    
    @SerializedName("delivery_fee")
    val deliveryFee: Double,
    
    @SerializedName("service_fee")
    val serviceFee: Double,
    
    @SerializedName("vat")
    val vat: Double,
    
    @SerializedName("tip")
    val tip: Double = 0.0,
    
    @SerializedName("total")
    val total: Double,
    
    @SerializedName("status")
    val status: String = "pending",
    
    @SerializedName("payment_method")
    val paymentMethod: String = "cod",
    
    @SerializedName("created_at")
    val createdAt: String?
)

data class OrderItem(
    @SerializedName("menu_item_id")
    val menuItemId: String,
    
    @SerializedName("name")
    val name: String,
    
    @SerializedName("quantity")
    val quantity: Int,
    
    @SerializedName("price")
    val price: Double,
    
    @SerializedName("subtotal")
    val subtotal: Double
)

data class User(
    @SerializedName("username")
    val username: String,
    
    @SerializedName("email")
    val email: String,
    
    @SerializedName("fullName")
    val fullName: String?,
    
    @SerializedName("phone")
    val phone: String?,
    
    @SerializedName("role")
    val role: String?,
    
    @SerializedName("attributes")
    val attributes: Map<String, String>
)
