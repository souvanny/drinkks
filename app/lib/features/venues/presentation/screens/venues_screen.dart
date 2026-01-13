import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/venues_controller.dart';

class VenuesScreen extends ConsumerWidget {
  const VenuesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesState = ref.watch(venuesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Venues Feature'),
      ),
      body: venuesState.when(
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
          ref.read(venuesControllerProvider.notifier).refresh(); // Or specialized method
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
