package com.zhigo.customer.ui.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.zhigo.customer.ui.screens.LoginScreen
import com.zhigo.customer.ui.screens.RestaurantListScreen
import com.zhigo.customer.ui.screens.RestaurantDetailScreen
import com.zhigo.customer.ui.viewmodels.AuthViewModel

sealed class Screen(val route: String) {
    object Login : Screen("login")
    object RestaurantList : Screen("restaurants")
    object RestaurantDetail : Screen("restaurant/{restaurantId}") {
        fun createRoute(restaurantId: String) = "restaurant/$restaurantId"
    }
    object Checkout : Screen("checkout")
    object Orders : Screen("orders")
    object Profile : Screen("profile")
}

@Composable
fun NavGraph(
    navController: NavHostController = rememberNavController(),
    authViewModel: AuthViewModel = hiltViewModel()
) {
    val isAuthenticated by authViewModel.isAuthenticated.collectAsState()
    
    val startDestination = if (isAuthenticated) {
        Screen.RestaurantList.route
    } else {
        Screen.Login.route
    }

    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable(Screen.Login.route) {
            LoginScreen(
                onNavigateToRestaurants = {
                    navController.navigate(Screen.RestaurantList.route) {
                        popUpTo(Screen.Login.route) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.RestaurantList.route) {
            RestaurantListScreen(
                onRestaurantClick = { restaurantId ->
                    navController.navigate(Screen.RestaurantDetail.createRoute(restaurantId))
                },
                onNavigateToProfile = {
                    navController.navigate(Screen.Profile.route)
                }
            )
        }

        composable(Screen.RestaurantDetail.route) { backStackEntry ->
            val restaurantId = backStackEntry.arguments?.getString("restaurantId") ?: ""
            RestaurantDetailScreen(
                restaurantId = restaurantId,
                onNavigateBack = { navController.popBackStack() },
                onNavigateToCheckout = {
                    navController.navigate(Screen.Checkout.route)
                }
            )
        }
    }
}
