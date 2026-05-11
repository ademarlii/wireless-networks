import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/constants.dart';

class AttendanceRepository {
  final ApiClient _apiClient = ApiClient();

  String _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      return decoded['message'] ?? 'Bilinmeyen bir hata oluştu.';
    } catch (_) {
      return 'Sunucu ile iletişim kurulamadı.';
    }
  }

  Future<ApiResult<bool>> checkin(String sessionId) async {
    try {
      final response = await _apiClient.post(
        AppConstants.checkin,
        body: {'sessionId': sessionId},
      );
      if (response.statusCode == 201) {
        return const ApiSuccess(true);
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
      return ApiError('Check-in başarısız: İnternet bağlantınızı kontrol edin.');
    }
  }

  Future<ApiResult<bool>> sendHeartbeat(String sessionId) async {
    try {
      final response = await _apiClient.post(
        AppConstants.heartbeat,
        body: {'sessionId': sessionId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const ApiSuccess(true);
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
      return ApiError('Heartbeat gönderilemedi.');
    }
  }

  Future<ApiResult<bool>> signalLost(String sessionId) async {
    try {
      final response = await _apiClient.post(
        AppConstants.signalLost,
        body: {'sessionId': sessionId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return const ApiSuccess(true);
      } else {
        return ApiError(_extractErrorMessage(response.body));
      }
    } catch (e) {
      return ApiError('Sinyal kaybı bildirilemedi.');
    }
  }
}
