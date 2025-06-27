import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:treqsy_platform/data/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:treqsy_platform/providers/auth_provider.dart';

// Provider for dashboard data
final dashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(apiServiceProvider).getWalletAnalytics();
});

// Provider for the list of users
final userListProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(apiServiceProvider).listUsers();
});

class MasterAdminDashboard extends ConsumerStatefulWidget {
  const MasterAdminDashboard({super.key});

  @override
  ConsumerState<MasterAdminDashboard> createState() => _MasterAdminDashboardState();
}

class _MasterAdminDashboardState extends ConsumerState<MasterAdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Users'),
            Tab(text: 'Wallet'),
            Tab(text: 'Coin Analytics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardOverview(),
          _UserManagementSection(),
          _WalletAnalyticsTab(),
          _CoinAnalyticsTab(),
        ],
      ),
    );
  }
}

class _DashboardOverview extends ConsumerWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider);
    return dataAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Text('Error: $err'),
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard Overview', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              children: [
                _KpiCard(title: 'Total Revenue', value: '₹${data['total_revenue'] ?? 0}'),
                _KpiCard(title: 'Active Streams', value: (data['active_streams'] ?? 0).toString()),
                _KpiCard(title: 'New Users Today', value: (data['new_users_today'] ?? 0).toString()),
                _KpiCard(title: 'Avg. Watch Time', value: '${data['avg_watch_time_minutes'] ?? 0} min'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Revenue (Last 7 Days)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: (data['revenue_last_7_days'] as List<dynamic>).asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value['revenue'].toDouble());
                      }).toList(),
                      isCurved: true,
                      barWidth: 3,
                      color: Theme.of(context).primaryColor,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  const _KpiCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _UserManagementSection extends ConsumerWidget {
  const _UserManagementSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('User Management', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        usersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Text('Error: $err'),
          data: (users) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('VIP')),
                  DataColumn(label: Text('Active')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: users.map((user) {
                  return DataRow(cells: [
                    DataCell(Text(user['email'] ?? 'N/A')),
                    DataCell(Text(user['role'] ?? 'N/A')),
                    DataCell(
                      Switch(
                        value: user['is_vip'] ?? false,
                        onChanged: (isVip) {
                          ref.read(apiServiceProvider).toggleVipStatus(user['_id'], isVip)
                            .then((_) => ref.refresh(userListProvider));
                        },
                      ),
                    ),
                    DataCell(
                       Switch(
                        value: user['is_active'] ?? false,
                        onChanged: (isActive) {
                           ref.read(apiServiceProvider).activateUser(user['_id'], isActive)
                            .then((_) => ref.refresh(userListProvider));
                        },
                      ),
                    ),
                    DataCell(
                      DropdownButton<String>(
                        value: user['role'],
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('User')),
                          DropdownMenuItem(value: 'host', child: Text('Host')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'master_admin', child: Text('Master Admin')),
                        ],
                        onChanged: (role) {
                          if (role != null) {
                            ref.read(apiServiceProvider).changeUserRole(user['_id'], role)
                              .then((_) => ref.refresh(userListProvider));
                          }
                        },
                      ),
                    )
                  ]);
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _WalletAnalyticsTab extends ConsumerWidget {
  const _WalletAnalyticsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implementation of _WalletAnalyticsTab
    return Container(); // Placeholder, actual implementation needed
  }
}

class _CoinAnalyticsTab extends ConsumerStatefulWidget {
  const _CoinAnalyticsTab();
  @override
  ConsumerState<_CoinAnalyticsTab> createState() => _CoinAnalyticsTabState();
}

class _CoinAnalyticsTabState extends ConsumerState<_CoinAnalyticsTab> {
  Map<String, dynamic>? _analytics;
  Map<String, dynamic>? _settings;
  List<dynamic> _payoutRequests = [];
  String? _razorpayKey;
  bool _loading = true;
  final _priceController = TextEditingController();
  final _bonusController = TextEditingController();
  final _razorpayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final api = ref.read(apiServiceProvider);
    final analytics = await api.getCoinAnalytics();
    final settings = await api.getCoinSettings();
    final payouts = await api.getPendingPayoutRequests();
    final razorpayKey = await api.getRazorpayKey();
    _priceController.text = settings['coin_price'].toString();
    _bonusController.text = settings['bonus_rate'].toString();
    _razorpayController.text = razorpayKey;
    setState(() {
      _analytics = analytics;
      _settings = settings;
      _payoutRequests = payouts;
      _razorpayKey = razorpayKey;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final api = ref.read(apiServiceProvider);
    await api.setCoinSettings({
      'coin_price': int.parse(_priceController.text),
      'bonus_rate': double.parse(_bonusController.text),
    });
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coin settings updated')));
  }

  Future<void> _saveRazorpayKey() async {
    final api = ref.read(apiServiceProvider);
    await api.setRazorpayKey(_razorpayController.text.trim());
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Razorpay key updated')));
  }

  Future<void> _approvePayout(String requestId) async {
    final api = ref.read(apiServiceProvider);
    await api.approvePayout(requestId);
    await _loadData();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payout approved')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.secondaryContainer,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coin Analytics', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Text('Total Coins: ${_analytics?['total_coins'] ?? 0}'),
                  Text('Coins Purchased: ${_analytics?['coins_purchased'] ?? 0}'),
                  Text('Coins Spent: ${_analytics?['coins_spent'] ?? 0}'),
                  Text('Coins Payout: ${_analytics?['coins_payout'] ?? 0}'),
                  const SizedBox(height: 16),
                  Text('Top Spenders:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...((_analytics?['top_spenders'] ?? []) as List).map((e) => ListTile(
                        title: Text(e['email']),
                        trailing: Text('${e['coins']}'),
                      )),
                  const SizedBox(height: 8),
                  Text('Top Earners:', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...((_analytics?['top_earners'] ?? []) as List).map((e) => ListTile(
                        title: Text(e['email']),
                        trailing: Text('${e['coins']}'),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.secondaryContainer,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pending Payout Requests', style: theme.textTheme.titleMedium),
                  ..._payoutRequests.map((req) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text('User: ${req['user_id']}'),
                          subtitle: Text('Amount: ${req['amount']}'),
                          trailing: ElevatedButton(
                            onPressed: () => _approvePayout(req['_id']),
                            child: const Text('Approve'),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.secondaryContainer,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coin Settings', style: theme.textTheme.titleMedium),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Coin Price'),
                  ),
                  TextField(
                    controller: _bonusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bonus Rate'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveSettings,
                    child: const Text('Save Settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.secondaryContainer,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Razorpay Key Management', style: theme.textTheme.titleMedium),
                  TextField(
                    controller: _razorpayController,
                    decoration: const InputDecoration(labelText: 'Razorpay API Key'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveRazorpayKey,
                    child: const Text('Save Razorpay Key'),
                  ),
                  if (_razorpayKey != null && _razorpayKey!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Current Key: $_razorpayKey', style: theme.textTheme.bodySmall),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 