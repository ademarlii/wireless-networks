import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_result.dart';
import '../../../core/utils/constants.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded['message'] ?? 'Bilinmeyen bir hata oluştu.';
    } catch (_) {
      return 'Sunucu ile iletişim kurulamadı.';
    }
  }

  Future<ApiResult<bool>> registerStudent(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        AppConstants.registerStudent,
        body: data,
        requireAuth: false,
      );
      if (response.statusCode == 201) {
        return const ApiSuccess(true);
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
      return ApiError(e.toString());
    }
  }

  Future<ApiResult<UserModel>> verifyEmail(String email, String code) async {
    try {
      final response = await _apiClient.post(
        AppConstants.verifyEmail,
        body: {'email': email, 'code': code},
        requireAuth: false,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await SecureStorage.saveToken(data['token']);
        final user = UserModel.fromJson(data['user']);
        await SecureStorage.saveRole(user.role);
        return ApiSuccess(user);
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
      return const ApiError('Doğrulama başarısız.');
    }
  }

  Future<ApiResult<bool>> resendCode(String email) async {
    try {
      final response = await _apiClient.post(
        AppConstants.resendCode,
        body: {'email': email},
        requireAuth: false,
      );
      if (response.statusCode == 200) {
        return const ApiSuccess(true);
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
      return const ApiError('Kod gönderilemedi.');
    }
  }

  Future<ApiResult<UserModel>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        AppConstants.login,
        body: {'email': email, 'password': password},
        requireAuth: false,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await SecureStorage.saveToken(data['token']);
        final user = UserModel.fromJson(data['user']);
        await SecureStorage.saveRole(user.role);
        return ApiSuccess(user);
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
      return ApiError('Giriş başarısız: İnternet bağlantınızı kontrol edin.');
    }
  }

  Future<ApiResult<UserModel>> getProfile() async {
    try {
      final response = await _apiClient.get(AppConstants.getProfile);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiSuccess(UserModel.fromJson(data['user']));
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
       return ApiError('Profil bilgileri alınamadı.');
    }
  }
}
