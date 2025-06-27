import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:treqsy_platform/data/api_service.dart';
import 'package:treqsy_platform/domain/models/stream_session.dart';
import 'package:treqsy_platform/providers/auth_provider.dart';
import 'package:treqsy_platform/features/profile/profile_screen.dart';

final activeStreamsProvider = FutureProvider<List<StreamSession>>((ref) async {
  // This now depends on the user being logged in.
  final token = ref.watch(authProvider).token;
  if (token == null) return [];
  return ref.watch(apiServiceProvider).getActiveStreams();
});

class StreamsListScreen extends ConsumerWidget {
  const StreamsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamsAsyncValue = ref.watch(activeStreamsProvider);
    final currentUser = ref.watch(authProvider).user;

    return streamsAsyncValue.when(
      data: (streams) {
        if (streams.isEmpty) {
          return const Center(child: Text("No active streams right now."));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(activeStreamsProvider.future),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            itemCount: streams.length,
            itemBuilder: (context, index) {
              final stream = streams[index];
              final initials = stream.hostEmail.isNotEmpty
                  ? stream.hostEmail.substring(0, 2).toUpperCase()
                  : "ST";
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // TODO: Navigate to stream view
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          child: Text(initials, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          stream.title ?? 'Untitled Stream',
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stream.hostEmail,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to stream view
                          },
                          child: const Text('Watch'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
} 