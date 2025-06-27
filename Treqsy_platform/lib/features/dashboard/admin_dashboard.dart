import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:treqsy_platform/data/api_service.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(apiServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: FutureBuilder<List<dynamic>>(
        future: api.listUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final users = (snapshot.data ?? []).where((u) => u['role'] == 'host' || u['role'] == 'agency').toList();
          if (users.isEmpty) {
            return const Center(child: Text('No hosts or agencies found.'));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final user = users[i];
              return ListTile(
                title: Text(user['email'] ?? ''),
                subtitle: Text('Role: ${user['role']} | Active: ${user['is_active']}'),
                trailing: Switch(
                  value: user['is_active'] ?? true,
                  onChanged: (active) async {
                    await api.activateUser(user['_id'], active);
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User status updated')));
                    (context as Element).reassemble();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 