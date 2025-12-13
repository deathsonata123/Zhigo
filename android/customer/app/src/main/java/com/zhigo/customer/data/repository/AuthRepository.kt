package com.zhigo.customer.data.repository

import com.zhigo.customer.data.api.ApiService
import com.zhigo.customer.data.api.SignInRequest
import com.zhigo.customer.data.api.SignUpRequest
import com.zhigo.customer.data.api.ConfirmRequest
import com.zhigo.customer.data.api.AuthTokens
import com.zhigo.customer.data.local.TokenManager
import com.zhigo.customer.data.models.User
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthRepository @Inject constructor(
    private val apiService: ApiService,
    private val tokenManager: TokenManager
) {

    suspend fun signIn(email: String, password: String): Result<AuthTokens> {
        return try {
            val response = apiService.signIn(SignInRequest(email, password))
            
            if (response.isSuccessful && response.body()?.success == true) {
                val tokens = response.body()!!.data!!
                tokenManager.saveTokens(
                    tokens.accessToken,
                    tokens.idToken,
                    tokens.refreshToken
                )
                Result.success(tokens)
            } else {
                Result.failure(Exception(response.body()?.error ?: "Sign in failed"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun signUp(
        email: String,
        password: String,
        fullName: String,
        phone: String? = null
    ): Result<Boolean> {
        return try {
            val response = apiService.signUp(
                SignUpRequest(email, password, fullName, phone)
            )
            
            if (response.isSuccessful && response.body()?.success == true) {
                Result.success(true)
            } else {
                Result.failure(Exception(response.body()?.error ?: "Sign up failed"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun confirmSignUp(email: String, code: String): Result<Boolean> {
        return try {
            val response = apiService.confirmSignUp(ConfirmRequest(email, code))
            
            if (response.isSuccessful && response.body()?.success == true) {
                Result.success(true)
            } else {
                Result.failure(Exception(response.body()?.error ?: "Confirmation failed"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    suspend fun signOut(): Result<Boolean> {
        return try {
            val token = tokenManager.getAccessToken()
            if (token != null) {
                apiService.signOut("Bearer $token")
            }
            tokenManager.clearTokens()
            Result.success(true)
        } catch (e: Exception) {
            tokenManager.clearTokens()
            Result.success(true)
        }
    }

    suspend fun getCurrentUser(): Result<User> {
        return try {
            val token = tokenManager.getAccessToken()
                ?: return Result.failure(Exception("Not authenticated"))
            
            val response = apiService.getCurrentUser("Bearer $token")
            
            if (response.isSuccessful && response.body()?.success == true) {
                Result.success(response.body()!!.data!!)
            } else {
                Result.failure(Exception(response.body()?.error ?: "Failed to get user"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }

    fun isAuthenticated(): Boolean {
        return tokenManager.isAuthenticated()
    }
}
