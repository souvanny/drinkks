import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// Test simple
class TestNotifier extends StateNotifier<int> {
  TestNotifier() : super(0);
}

final testProvider = StateNotifierProvider<TestNotifier, int>((ref) {
  return TestNotifier();
});

void main() {
  print('✅ Si ce fichier compile, StateNotifier est disponible');
}