import 'package:dio/dio.dart';
import '../network/api_client.dart';

class ApiService {
  ApiService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  // Helper method for GET requests
  Future<Response<T>> _get<T>(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _apiClient.dio.get<T>(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Helper method for POST requests
  Future<Response<T>> _post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _apiClient.dio.post<T>(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final response = e.response;
    if (response != null && response.data != null) {
      final data = response.data;
      if (data is Map && data.containsKey('message')) {
        return Exception(data['message']);
      }
    }
    return Exception(e.message ?? 'An unexpected network error occurred');
  }

  // ── AUTHENTICATION ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendRegistrationOtp(String phoneNumber) async {
    final response = await _post<Map<String, dynamic>>(
      '/auth/otp/registration',
      data: {'phoneNumber': phoneNumber},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String otpCode,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
        'firstName': firstName,
        'lastName': lastName,
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> setPin({
    required String phoneNumber,
    required String otpCode,
    required String pin,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/auth/pin/set',
      data: {
        'phoneNumber': phoneNumber,
        'otpCode': otpCode,
        'pin': pin,
      },
    );
    return response.data ?? {};
  }

  Future<void> changePin({
    required String oldPin,
    required String newPin,
    required String confirmNewPin,
  }) async {
    await _post<Map<String, dynamic>>(
      '/auth/pin/change',
      data: {
        'oldPin': oldPin,
        'newPin': newPin,
        'confirmNewPin': confirmNewPin,
      },
    );
  }

  Future<Map<String, dynamic>> sendPinSetupOtp(String phoneNumber) async {
    final response = await _post<Map<String, dynamic>>(
      '/auth/otp/pin-setup',
      data: {'phoneNumber': phoneNumber},
    );
    return response.data ?? {};
  }

  // ── WALLET / PROFILE ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await _get<Map<String, dynamic>>('/wallets/balance');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _get<Map<String, dynamic>>('/account/profile');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getTransactionHistory({String? cursor, int limit = 20}) async {
    final response = await _get<Map<String, dynamic>>(
      '/transactions',
      queryParameters: {
        'cursor': ?cursor,
        'limit': limit,
      },
    );
    return response.data ?? {};
  }

  // ── KYC VERIFICATION ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> verifyBvn(String bvn) async {
    final response = await _post<Map<String, dynamic>>(
      '/kyc/verify/bvn',
      data: {'bvn': bvn},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> verifyNin(String nin) async {
    final response = await _post<Map<String, dynamic>>(
      '/kyc/verify/nin',
      data: {'nin': nin},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getKycStatus() async {
    final response = await _get<Map<String, dynamic>>('/kyc/status');
    return response.data ?? {};
  }

  Future<bool> isKycVerified() async {
    final response = await _get<Map<String, dynamic>>('/kyc/check');
    final data = response.data ?? {};
    return data['data'] == true;
  }

  // ── TRANSFERS ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getBankList() async {
    final response = await _get<Map<String, dynamic>>('/transfers/nip/banks');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> nameEnquiry({
    required String bankCode,
    required String accountNumber,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/transfers/nip/name-enquiry',
      data: {
        'bankCode': bankCode,
        'accountNumber': accountNumber,
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> estimateFee(double amount) async {
    final response = await _post<Map<String, dynamic>>(
      '/transfers/nip/fee-estimate',
      data: {'amount': amount},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> initiateNipTransfer({
    required String bankCode,
    required String accountNumber,
    required String accountName,
    required String sessionId,
    required double amount,
    String? description,
    required String pin,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/transfers/nip',
      data: {
        'recipientBankCode': bankCode,
        'recipientAccountNumber': accountNumber,
        'recipientAccountName': accountName,
        'nameEnquirySessionId': sessionId,
        'amount': amount,
        'description': description ?? '',
        'pin': pin,
        'idempotencyKey': 'nip_${DateTime.now().microsecondsSinceEpoch}',
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> lookupP2PRecipient(String identifier) async {
    final response = await _post<Map<String, dynamic>>(
      '/transfers/p2p/recipient-lookup',
      queryParameters: {'identifier': identifier},
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> p2pTransfer({
    required String recipientIdentifier,
    required double amount,
    required String pin,
    String? description,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/transfers/p2p',
      data: {
        'recipientIdentifier': recipientIdentifier,
        'amountNaira': amount,
        'pin': pin,
        'description': description ?? '',
        'idempotencyKey': 'p2p_${DateTime.now().microsecondsSinceEpoch}',
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getP2pTransferHistory({int limit = 20}) async {
    final response = await _get<Map<String, dynamic>>(
      '/transfers/p2p/history',
      queryParameters: {'limit': limit},
    );
    return response.data ?? {};
  }

  // ── BILLS ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> purchaseAirtime({
    required String walletId,
    required String providerCode,
    required String phoneNumber,
    required double amount,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/bills/airtime',
      data: {
        'walletId': walletId,
        'providerCode': providerCode,
        'phoneNumber': phoneNumber,
        'amountNaira': amount,
        'idempotencyKey': 'airtime_${DateTime.now().microsecondsSinceEpoch}',
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getDataVariations(String providerCode) async {
    final response = await _get<Map<String, dynamic>>('/bills/data/variations/$providerCode');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> purchaseData({
    required String walletId,
    required String providerCode,
    required String variationCode,
    required String phoneNumber,
    required double amount,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/bills/data',
      data: {
        'walletId': walletId,
        'providerCode': providerCode,
        'variationCode': variationCode,
        'phoneNumber': phoneNumber,
        'amountNaira': amount,
        'idempotencyKey': 'data_${DateTime.now().microsecondsSinceEpoch}',
      },
    );
    return response.data ?? {};
  }

  // ── SAVINGS ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getSavingsAccounts() async {
    final response = await _get<Map<String, dynamic>>('/savings/accounts');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> depositToSavings({
    required String savingsAccountId,
    required double amountNaira,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/savings/deposit',
      data: {
        'savingsAccountId': savingsAccountId,
        'amountNaira': amountNaira,
        'idempotencyKey': 'sav_dep_${DateTime.now().microsecondsSinceEpoch}',
      },
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> withdrawFromSavings({
    required String savingsAccountId,
    required double amountNaira,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/savings/withdraw',
      data: {
        'savingsAccountId': savingsAccountId,
        'amountNaira': amountNaira,
        'idempotencyKey': 'sav_wdr_${DateTime.now().microsecondsSinceEpoch}',
      },
    );
    return response.data ?? {};
  }

  // ── LOANS ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMyLoans() async {
    final response = await _get<Map<String, dynamic>>('/loans/my-loans');
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> applyForLoan({
    required String schoolId,
    required double amountNaira,
    required String purpose,
    required String academicLevel,
    required String academicSession,
  }) async {
    final response = await _post<Map<String, dynamic>>(
      '/loans/apply',
      data: {
        'schoolId': schoolId,
        'amountNaira': amountNaira,
        'purpose': purpose,
        'academicLevel': academicLevel,
        'academicSession': academicSession,
        'idempotencyKey': 'loan_${DateTime.now().microsecondsSinceEpoch}',
      },
    );
    return response.data ?? {};
  }

  // ── NOTIFICATIONS ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getNotifications({
    int page = 0,
    int size = 20,
    bool? unreadOnly,
  }) async {
    final response = await _get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: {
        'page': page,
        'size': size,
        'unreadOnly': ?unreadOnly,
      },
    );
    return response.data ?? {};
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _post<Map<String, dynamic>>('/notifications/$notificationId/read');
  }
}
