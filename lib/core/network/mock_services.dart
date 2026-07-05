import 'package:flutter/foundation.dart';

class MockLocationService {
  static final Map<String, Map<String, String>> _pincodes = {
    '400001': {'city': 'Mumbai', 'state': 'Maharashtra'},
    '110001': {'city': 'New Delhi', 'state': 'Delhi'},
    '560001': {'city': 'Bengaluru', 'state': 'Karnataka'},
    '600001': {'city': 'Chennai', 'state': 'Tamil Nadu'},
    '700001': {'city': 'Kolkata', 'state': 'West Bengal'},
    '500001': {'city': 'Hyderabad', 'state': 'Telangana'},
    '411001': {'city': 'Pune', 'state': 'Maharashtra'},
    '380001': {'city': 'Ahmedabad', 'state': 'Gujarat'},
  };

  static Future<Map<String, String>?> getDetailsFromPincode(String pincode) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _pincodes[pincode];
  }
}

class MockPanService {
  static Future<Map<String, dynamic>> verify(String pan, List<String> usedPans) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final RegExp panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panPattern.hasMatch(pan)) {
      return {'valid': false, 'error': 'Invalid PAN format'};
    }
    
    if (usedPans.contains(pan)) {
      return {'valid': false, 'error': 'PAN already registered'};
    }
    
    return {'valid': true, 'name': 'TEST USER NAME'};
  }
}

class MockKycService {
  static Future<void> uploadDocument(String docType, String filePath) async {
    // Simulates an upload process
    await Future.delayed(const Duration(seconds: 2));
  }
}

class MockIfscService {
  static final Map<String, Map<String, String>> _ifscMap = {
    'SBIN0000001': {'bank': 'State Bank of India', 'branch': 'Main Branch Mumbai'},
    'HDFC0000001': {'bank': 'HDFC Bank', 'branch': 'Connaught Place Delhi'},
    'ICIC0000001': {'bank': 'ICICI Bank', 'branch': 'Chennai Main'},
    'UTIB0000001': {'bank': 'Axis Bank', 'branch': 'Hyderabad Central'},
  };

  static Future<Map<String, String>> lookup(String ifsc) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (_ifscMap.containsKey(ifsc)) {
      return _ifscMap[ifsc]!;
    }
    
    // Fallback for valid format but not in map
    return {'bank': 'Bank of India', 'branch': 'Local Branch'};
  }
}
