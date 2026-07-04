import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:viora_app/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:viora_app/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:viora_app/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:viora_app/features/wallet/presentation/pages/payment_webview_page.dart';
import 'package:viora_app/features/wallet/presentation/widgets/recharge_sheet.dart';
import 'package:viora_app/features/wallet/presentation/widgets/transaction_tile.dart';
import 'package:viora_app/features/wallet/presentation/widgets/wallet_card.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(const LoadWallet());
  }

  void _showRechargeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: const RechargeSheet(),
      ),
    ).then((amount) {
      if (amount != null && amount is double && mounted) {
        context.read<WalletBloc>().add(RechargeWallet(amount));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state.status == WalletStatus.success && state.paymentUrl != null) {
          final bloc = context.read<WalletBloc>();
          Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => PaymentWebViewPage(
                paymentUrl: state.paymentUrl!,
              ),
            ),
          ).then((_) {
            bloc.add(const LoadWallet());
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Success in charging the wallet',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF0D7C66),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          });
        }
        if (state.status == WalletStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          context.read<WalletBloc>().add(const LoadWallet());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7FFFD),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1A2E), size: 20),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'My Wallet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0D7C66)),
                onPressed: () => context.read<WalletBloc>().add(const LoadWallet()),
              ),
            ],
          ),
          body: _buildBody(state),
          floatingActionButton: state.wallet != null
              ? FloatingActionButton.extended(
                  onPressed: _showRechargeSheet,
                  backgroundColor: const Color(0xFF0D7C66),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Charge',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildBody(WalletState state) {
    if (state.isLoading && state.wallet == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0D7C66)),
      );
    }

    if (state.status == WalletStatus.error && state.wallet == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 50,
                  color: Color(0xFFEF4444),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No Wallet Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? 'Create a wallet to get started.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.read<WalletBloc>().add(const OpenWallet()),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create Wallet'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7C66),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final wallet = state.wallet;
    if (wallet == null) return const SizedBox.shrink();

    return RefreshIndicator(
      color: const Color(0xFF0D7C66),
      onRefresh: () async {
        context.read<WalletBloc>().add(const LoadWallet());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            WalletCardWidget(wallet: wallet),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.3,
                  ),
                ),
                if (state.isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0D7C66),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (wallet.transactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8E8EE)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add money to your wallet to get started.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...wallet.transactions.map(
                (tx) => TransactionTile(transaction: tx),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
