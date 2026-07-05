import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../network/api_service.dart';

final userProvider = FutureProvider<UserModel>((ref) async {
  final data = await ApiService.getProfile();
  return UserModel.fromJson(data);
});
