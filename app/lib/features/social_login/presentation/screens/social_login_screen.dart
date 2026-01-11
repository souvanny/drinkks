import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/social_login_controller.dart';

class SocialLoginScreen extends ConsumerWidget {
  const SocialLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socialLoginState = ref.watch(socialLoginControllerProvider);


    ref.listen(socialLoginControllerProvider, (previous, next) {

      print("SocialLoginScreen LISTEN ======");


    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('SocialLogin Feature'),
      ),
      body: socialLoginState.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              title: Text(item.name),
              subtitle: Text(item.id),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(socialLoginControllerProvider.notifier).refresh(); // Or specialized method
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
