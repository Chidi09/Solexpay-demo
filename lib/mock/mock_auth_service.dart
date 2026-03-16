import '../core/constants/demo_data.dart';
import '../shared/models/user_profile.dart';

class MockAuthService {
  const MockAuthService();

  Future<UserProfile> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return demoUserProfile;
  }
}
