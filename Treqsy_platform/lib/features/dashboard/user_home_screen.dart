import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:treqsy_platform/providers/auth_provider.dart';
import 'package:treqsy_platform/features/streaming/streams_list_screen.dart';
import 'package:treqsy_platform/features/profile/wallet_screen.dart';
import 'package:treqsy_platform/data/api_service.dart';
import 'package:treqsy_platform/models/user_model.dart';

final hostsProvider = FutureProvider<List<User>>((ref) async {
  return ref.watch(apiServiceProvider).getAllHosts();
});

class UserHomeScreen extends ConsumerWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final hostsAsync = ref.watch(hostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treqsy'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final user = ref.watch(authProvider).user;
              return Padding(
                padding: const EdgeInsets.only(right: 12, top: 8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const CoinPurchaseScreen()),
                    );
                  },
                  child: Chip(
                    avatar: const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                    label: Text('${user?.coins ?? 0}'),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Welcome, ${user?.email ?? 'User'}!'),
          ),
          hostsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading hosts: $err'),
            ),
            data: (hosts) => hosts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No hosts available.'),
                  )
                : SizedBox(
                    height: 160,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: hosts.length,
                      itemBuilder: (context, i) {
                        final host = hosts[i];
                        final initials = host.email.isNotEmpty ? host.email.substring(0, 2).toUpperCase() : 'HO';
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                                ),
                                const SizedBox(height: 10),
                                Text(host.email, style: Theme.of(context).textTheme.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          const Expanded(
            child: StreamsListScreen(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.monetization_on),
        label: const Text('Purchase Coins'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WalletScreen()),
          );
        },
      ),
    );
  }
} 