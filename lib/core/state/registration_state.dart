import 'package:flutter/material.dart';

class RegistrationState extends ChangeNotifier {
  String? _phoneNumber;
  String? _otpReference;
  String? _otpCode;
  String? _bvn;

  String? get phoneNumber => _phoneNumber;
  String? get otpReference => _otpReference;
  String? get otpCode => _otpCode;
  String? get bvn => _bvn;

  void setPhoneAndReference(String phone, String reference) {
    _phoneNumber = phone;
    _otpReference = reference;
    notifyListeners();
  }

  void setOtpCode(String code) {
    _otpCode = code;
    notifyListeners();
  }

  void setBvn(String bvnValue) {
    _bvn = bvnValue;
    notifyListeners();
  }

  void clear() {
    _phoneNumber = null;
    _otpReference = null;
    _otpCode = null;
    _bvn = null;
    notifyListeners();
  }
}
