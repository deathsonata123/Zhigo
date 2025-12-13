package com.zhigo.customer.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.zhigo.customer.data.repository.AuthRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<AuthUiState>(AuthUiState.Idle)
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    private val _isAuthenticated = MutableStateFlow(authRepository.isAuthenticated())
    val isAuthenticated: StateFlow<Boolean> = _isAuthenticated.asStateFlow()

    fun signIn(email: String, password: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            
            val result = authRepository.signIn(email, password)
            
            _uiState.value = if (result.isSuccess) {
                _isAuthenticated.value = true
                AuthUiState.Success("Signed in successfully")
            } else {
                AuthUiState.Error(result.exceptionOrNull()?.message ?: "Sign in failed")
            }
        }
    }

    fun signUp(email: String, password: String, fullName: String, phone: String?) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            
            val result = authRepository.signUp(email, password, fullName, phone)
            
            _uiState.value = if (result.isSuccess) {
                AuthUiState.Success("Account created! Please check your email for confirmation code.")
            } else {
                AuthUiState.Error(result.exceptionOrNull()?.message ?: "Sign up failed")
            }
        }
    }

    fun confirmSignUp(email: String, code: String) {
        viewModelScope.launch {
            _uiState.value = AuthUiState.Loading
            
            val result = authRepository.confirmSignUp(email, code)
            
            _uiState.value = if (result.isSuccess) {
                AuthUiState.Success("Email confirmed! You can now sign in.")
            } else {
                AuthUiState.Error(result.exceptionOrNull()?.message ?: "Confirmation failed")
            }
        }
    }

    fun signOut() {
        viewModelScope.launch {
            authRepository.signOut()
            _isAuthenticated.value = false
            _uiState.value = AuthUiState.Idle
        }
    }

    fun resetState() {
        _uiState.value = AuthUiState.Idle
    }
}

sealed class AuthUiState {
    object Idle : AuthUiState()
    object Loading : AuthUiState()
    data class Success(val message: String) : AuthUiState()
    data class Error(val message: String) : AuthUiState()
}
