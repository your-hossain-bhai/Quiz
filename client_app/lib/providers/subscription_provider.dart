import 'package:flutter/material.dart';
import '../services/bdapps_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SubscriptionState { inputPhone, inputOtp, subscribed, error }

class SubscriptionProvider extends ChangeNotifier {
  final BdAppsService _bdAppsService = BdAppsService();
  
  SubscriptionState _state = SubscriptionState.inputPhone;
  SubscriptionState get state => _state;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  String _referenceNo = '';
  String _phoneNumber = '';
  
  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;

  SubscriptionProvider() {
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isSubscribed = prefs.getBool('isSubscribed') ?? false;
    if (_isSubscribed) {
      _state = SubscriptionState.subscribed;
      notifyListeners();
    }
  }
  
  Future<void> sendOtp(String phoneNumber) async {
    _setLoading(true);
    _phoneNumber = phoneNumber;
    try {
      final response = await _bdAppsService.sendOtp(phoneNumber);
      if (response['success'] == true && response['referenceNo'] != null) {
        _referenceNo = response['referenceNo'];
        _state = SubscriptionState.inputOtp;
        _errorMessage = '';
      } else {
        _state = SubscriptionState.error;
        _errorMessage = response['message'] ?? 'Failed to send OTP';
      }
    } catch (e) {
      _state = SubscriptionState.error;
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> verifyOtp(String otp) async {
    _setLoading(true);
    try {
      final response = await _bdAppsService.verifyOtp(_referenceNo, otp);
      if (response['statusCode'] == 'S1000' || response['subscriptionStatus'] == 'REGISTERED') {
        _state = SubscriptionState.subscribed;
        _isSubscribed = true;
        _errorMessage = '';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isSubscribed', true);
        await prefs.setString('subscriberId', response['subscriberId'] ?? '');
      } else {
        _errorMessage = response['statusDetail'] ?? 'Failed to verify OTP';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkSubscriptionStatus() async {
    if (_phoneNumber.isEmpty) return;
    
    _setLoading(true);
    try {
      final response = await _bdAppsService.checkSubscription(_phoneNumber);
      if (response['isSubscribed'] == true) {
        _state = SubscriptionState.subscribed;
        _isSubscribed = true;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isSubscribed', true);
      } else {
        _isSubscribed = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isSubscribed', false);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  void reset() {
    _state = SubscriptionState.inputPhone;
    _errorMessage = '';
    notifyListeners();
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
