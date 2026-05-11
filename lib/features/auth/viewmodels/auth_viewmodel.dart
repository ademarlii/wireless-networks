import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/utils/base_state.dart';
import '../../../core/network/api_result.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

final authViewModelProvider = NotifierProvider<AuthViewModel, BaseState<UserModel>>(() {
  return AuthViewModel();
});

class AuthViewModel extends Notifier<BaseState<UserModel>> {
  late AuthRepository _repository;

  @override
  BaseState<UserModel> build() {
    _repository = ref.read(authRepositoryProvider);
    _checkAuthStatus();
    return BaseState<UserModel>();
  }

  Future<void> _checkAuthStatus() async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      state = state.copyWith(status: ViewState.loading);
      final result = await _repository.getProfile();
      if (result is ApiSuccess<UserModel>) {
        state = state.copyWith(status: ViewState.success, data: result.data);
      } else {
        await SecureStorage.clearAll();
        state = state.copyWith(status: ViewState.error, errorMessage: 'Oturum süresi doldu. Lütfen tekrar giriş yapın.');
      }
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: ViewState.loading, errorMessage: null);
    
    final result = await _repository.login(email, password);
    
    if (result is ApiSuccess<UserModel>) {
      state = state.copyWith(status: ViewState.success, data: result.data);
    } else if (result is ApiError<UserModel>) {
      state = state.copyWith(status: ViewState.error, errorMessage: result.message);
    }
  }
  
  Future<void> register(Map<String, dynamic> data) async {
    state = state.copyWith(status: ViewState.loading, errorMessage: null);
    
    final result = await _repository.registerStudent(data);
    
    if (result is ApiSuccess<bool>) {
      state = state.copyWith(status: ViewState.success); // Navigate to Verify
    } else if (result is ApiError<bool>) {
      state = state.copyWith(status: ViewState.error, errorMessage: result.message);
    }
  }

  Future<void> verifyEmail(String email, String code) async {
    state = state.copyWith(status: ViewState.loading, errorMessage: null);
    
    final result = await _repository.verifyEmail(email, code);
    
    if (result is ApiSuccess<UserModel>) {
      state = state.copyWith(status: ViewState.success, data: result.data); // Login successful basically
    } else if (result is ApiError<UserModel>) {
      state = state.copyWith(status: ViewState.error, errorMessage: result.message);
    }
  }

  Future<void> resendCode(String email) async {
    state = state.copyWith(status: ViewState.loading, errorMessage: null);
    
    final result = await _repository.resendCode(email);
    
    if (result is ApiSuccess<bool>) {
      state = state.copyWith(status: ViewState.initial); // Just to reset loading, or handle it via a separate provider/toast
    } else if (result is ApiError<bool>) {
      state = state.copyWith(status: ViewState.error, errorMessage: result.message);
    }
  }

  Future<void> logout() async {
    await SecureStorage.clearAll();
    state = BaseState<UserModel>(status: ViewState.initial);
  }
}
