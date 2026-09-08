import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart' show AppColors;
import '../../../core/theme/fonts_manager.dart' show MyFonts;
import '../../../core/theme/textfont_styles.dart' show getRegularStyle, getBoldStyle, getExtraBoldStyle, getSemiBoldStyle;
import 'controller.dart';
import 'model/response.dart';

class WalletHistoryView extends StatefulWidget {
  const WalletHistoryView({super.key});

  @override
  State<WalletHistoryView> createState() => _WalletHistoryViewState();
}

class _WalletHistoryViewState extends State<WalletHistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletController>().loadWalletData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Wallet',
          style: getExtraBoldStyle(
            fontSize: MyFonts.size22,
            color: AppColors.text,
          ),
        ),
      ),
      body: Consumer<WalletController>(
        builder: (context, wallet, _) {
          if (wallet.isLoading && wallet.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: wallet.loadWalletData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _balanceCard(wallet),
                  const SizedBox(height: 26),
                  Text(
                    'Transaction History',
                    style: getBoldStyle(
                      fontSize: MyFonts.size17,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (wallet.transactions.isEmpty)
                    _emptyState()
                  else
                    ...wallet.transactions
                        .map((t) => _transactionTile(t))
                        .toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- BALANCE CARD ----
  Widget _balanceCard(WalletController wallet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Wallet Balance',
                style: getSemiBoldStyle(
                  fontSize: MyFonts.size13,
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Rs ${wallet.walletAmount.toStringAsFixed(0)}',
            style: getExtraBoldStyle(
              fontSize: MyFonts.size32,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---- TRANSACTION TILE ----
  Widget _transactionTile(WalletTransaction t) {
    double amount = double.tryParse('${t.amount}') ?? 0;
    bool isCredit = t.loyaltyConvertPackageId != null ||
        (t.type ?? '').toLowerCase().contains('credit');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? Colors.green : AppColors.error)
                  .withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: isCredit ? Colors.green : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              t.description ?? (isCredit ? 'Amount Added' : 'Amount Used'),
              style: getSemiBoldStyle(
                fontSize: MyFonts.size13,
                color: AppColors.text,
              ),
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}Rs ${amount.toStringAsFixed(0)}',
            style: getBoldStyle(
              fontSize: MyFonts.size14,
              color: isCredit ? Colors.green : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ---- EMPTY STATE ----
  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.greyText.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: getSemiBoldStyle(
              fontSize: MyFonts.size14,
              color: AppColors.greyText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your wallet activity will show up here',
            textAlign: TextAlign.center,
            style: getRegularStyle(
              fontSize: MyFonts.size12,
              color: AppColors.greyText.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}