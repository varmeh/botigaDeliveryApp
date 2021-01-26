import 'package:flutter/foundation.dart';
import '../models/profile/index.dart';
import '../util/index.dart' show Http, Token;

class ProfileProvider with ChangeNotifier {
  Profile _profile;
  bool _hasProfile = false;

  get hasProfile {
    return this._hasProfile;
  }

  get allApartment {
    if (this._profile != null) {
      return this._profile.apartments;
    }
  }

  get totalApartment {
    if (this._profile != null && this._profile.apartments != null) {
      return this._profile.apartments.length;
    }
    return 0;
  }

  get defaultApartment {
    if (this._profile != null && this._profile.apartments.length > 0) {
      return this._profile.apartments.first;
    }
  }

  get profileInfo {
    return this._profile;
  }

  String getApartmentName(String apartmentid) {
    if (this._profile != null && this._profile.apartments != null) {
      Apartment apartment = this
          ._profile
          .apartments
          .firstWhere((apt) => apt.id == apartmentid, orElse: () => null);
      if (apartment == null) {
        return '';
      } else {
        return apartment.apartmentName;
      }
    }
    return '';
  }

  Future fetchProfile() async {
    final response = await Http.get('/api/seller/profile');
    this._profile = Profile.fromJson(response);
    this._hasProfile = true;
    notifyListeners();
  }

  Future restProfile() async {
    this._profile = null;
    this._hasProfile = false;
    notifyListeners();
  }

  Future signInWithPin(String phone, String pin) async {
    return Http.postAuth('/api/seller/auth/signin/pin',
        body: {'phone': phone, 'pin': pin});
  }

  Future getOTP(String phone) async {
    return Http.get('/api/seller/auth/otp/$phone');
  }

  Future verifyOtp(String phone, String sessionId, String otpVal) async {
    return await Http.postAuth('/api/seller/auth/otp/verify',
        body: {'phone': phone, 'sessionId': sessionId, 'otpVal': otpVal});
  }

  Future logout() async {
    /*
    We set token to '' and not as Null 
    to indicate user logged out and on second launch he can be 
    redirected to login screen 
    rather then intro screen.
    */
    await Http.post('/api/seller/auth/signout', body: {});
    return Token.write('');
  }
}
