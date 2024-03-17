// providers.dart
import 'package:riverpod/riverpod.dart';

final counterProvider = StateProvider<int>((ref) {
  return 0; // Initial value of your counter
});
