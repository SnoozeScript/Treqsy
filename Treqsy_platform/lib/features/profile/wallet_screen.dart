import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:treqsy_platform/data/api_service.dart';
import 'package:treqsy_platform/providers/auth_provider.dart';
import 'package:treqsy_platform/models/user_model.dart';
import 'package:flutter/services.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _loading = true;
  late User user;
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() => _loading = true);
    final api = ref.read(apiServiceProvider);
    final profile = await api.fetchUserProfile();
    final txs = await api.getCoinTransactions(profile.id!);
    setState(() {
      user = profile;
      _transactions = txs;
      _loading = false;
    });
  }

  void _showPurchaseDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Purchase Coins'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                await ref.read(apiServiceProvider).purchaseCoins(user.id!, amount);
                Navigator.pop(context);
                await _loadWallet();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coins purchased!')));
              }
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _showGiftDialog() {
    final emailController = TextEditingController();
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gift Coins'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Recipient Email'),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = int.tryParse(amountController.text);
              final toEmail = emailController.text.trim();
              if (amount != null && amount > 0 && toEmail.isNotEmpty) {
                await ref.read(apiServiceProvider).giftCoins(user.id!, toEmail, amount);
                Navigator.pop(context);
                await _loadWallet();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coins gifted!')));
              }
            },
            child: const Text('Gift'),
          ),
        ],
      ),
    );
  }

  void _showPayoutDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Payout'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = int.tryParse(controller.text);
              if (amount != null && amount > 0) {
                await ref.read(apiServiceProvider).requestPayout(user.id!, amount);
                Navigator.pop(context);
                await _loadWallet();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payout requested!')));
              }
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: theme.colorScheme.primaryContainer,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('Balance', style: theme.textTheme.titleMedium),
                  Text('${user.coins}', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
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
                  Row(
                    children: [
                      Icon(Icons.history, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text('Transaction History', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_transactions.isEmpty)
                    const Text('No transactions yet.'),
                  ..._transactions.map((tx) => ListTile(
                        leading: Icon(Icons.monetization_on, color: theme.colorScheme.primary),
                        title: Text(tx['type'] ?? 'Transaction'),
                        subtitle: Text(tx['details'] ?? ''),
                        trailing: Text('${tx['amount'] > 0 ? '+' : ''}${tx['amount']}', style: TextStyle(color: tx['amount'] > 0 ? Colors.green : Colors.red)),
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
                  Row(
                    children: [
                      Icon(Icons.add_circle, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Purchase Coins', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.payment),
                    label: const Text('Buy Coins'),
                    onPressed: _showPurchaseDialog,
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
                  Row(
                    children: [
                      Icon(Icons.card_giftcard, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Gift Coins', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Gift Coins'),
                    onPressed: _showGiftDialog,
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
                  Row(
                    children: [
                      Icon(Icons.request_page, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Request Payout', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Request Payout'),
                    onPressed: _showPayoutDialog,
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

class CoinPurchaseScreen extends ConsumerStatefulWidget {
  const CoinPurchaseScreen({Key? key}) : super(key: key);

  static final List<Map<String, dynamic>> coinPacks = [
    {'coins': 200, 'price': 79, 'badge': 'Popular'},
    {'coins': 500, 'price': 199},
    {'coins': 1200, 'price': 399, 'badge': 'Best Value'},
    {'coins': 2500, 'price': 799},
    {'coins': 5000, 'price': 1499},
  ];

  @override
  ConsumerState<CoinPurchaseScreen> createState() => _CoinPurchaseScreenState();
}

class _CoinPurchaseScreenState extends ConsumerState<CoinPurchaseScreen> with SingleTickerProviderStateMixin {
  bool _showConfetti = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSuccessAnimation() async {
    setState(() => _showConfetti = true);
    _controller.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _showConfetti = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Coins')),
      body: Stack(
        children: [
          Column(
            children: [
              // Fun header
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: Image.network(
                        'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                        height: 80,
                        width: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Get More Coins!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Unlock features, tip hosts, and more', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: CoinPurchaseScreen.coinPacks.length,
                  itemBuilder: (context, i) {
                    final pack = CoinPurchaseScreen.coinPacks[i];
                    final gradient = i % 2 == 0
                        ? [Colors.amber.shade200, Colors.orange.shade200]
                        : [Colors.blue.shade100, Colors.purple.shade100];
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.monetization_on, color: Colors.amber.shade700, size: 36),
                                const SizedBox(height: 10),
                                Text('${pack['coins']} Coins', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('₹${pack['price']}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.mediumImpact();
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Razorpay Payment'),
                                        content: Text('Pay ₹${pack['price']} for ${pack['coins']} coins?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Pay')),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await ref.read(apiServiceProvider).purchaseCoins(user!.id!, pack['coins']);
                                      await ref.read(apiServiceProvider).fetchUserProfile();
                                      _showSuccessAnimation();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Purchased ${pack['coins']} coins!')),
                                      );
                                      await Future.delayed(const Duration(milliseconds: 1200));
                                      if (mounted) Navigator.pop(context);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    curve: Curves.easeInOut,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade700,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.shade200.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.shopping_cart, color: Colors.white, size: 18),
                                        SizedBox(width: 8),
                                        Text('Buy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (pack['badge'] != null)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: pack['badge'] == 'Best Value' ? Colors.green : Colors.purple,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pack['badge'],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.7, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut)),
                    child: Image.network(
                      'https://cdn.pixabay.com/photo/2017/01/31/13/14/coins-2025794_1280.png',
                      width: 180,
                      height: 180,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 