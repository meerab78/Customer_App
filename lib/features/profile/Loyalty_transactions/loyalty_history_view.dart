import 'package:customer_app/features/profile/Loyalty_transactions/redemption_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart' show MyFonts;
import '../../../core/theme/textfont_styles.dart';
import '../../../core/utils/page_transitions.dart';
import 'controller.dart';
import 'model/response.dart';


class LoyaltyHistoryView extends StatefulWidget {
  const LoyaltyHistoryView({super.key});

  @override
  State<LoyaltyHistoryView> createState() => _LoyaltyHistoryViewState();
}

class _LoyaltyHistoryViewState extends State<LoyaltyHistoryView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoyaltyController>().loadLoyaltyData();
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
          'Loyalty Points',
          style: getExtraBoldStyle(
            fontSize: MyFonts.size22,
            color: AppColors.text,
          ),
        ),
      ),
      body: Consumer<LoyaltyController>(
        builder: (context, loyalty, _) {
          if (loyalty.isLoading && loyalty.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: loyalty.loadLoyaltyData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pointsSummaryCard(loyalty),
                  const SizedBox(height: 26),
                  Text(
                    'Transaction History',
                    style: getBoldStyle(
                      fontSize: MyFonts.size17,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (loyalty.transactions.isEmpty)
                    _emptyState()
                  else
                    ...loyalty.transactions
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

  // ---- POINTS SUMMARY + REDEEM CTA ----
  Widget _pointsSummaryCard(LoyaltyController loyalty) {
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
                  Icons.emoji_events_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Available Points',
                style: getSemiBoldStyle(
                  fontSize: MyFonts.size13,
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${loyalty.loyaltyPoints.toStringAsFixed(0)} pts',
            style: getExtraBoldStyle(
              fontSize: MyFonts.size32,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransitions.slideFromRight(const RedemptionView()),
                );
              },
              icon: const Icon(Icons.swap_horiz_rounded, size: 18),
              label: Text(
                'Redeem Points',
                style: getBoldStyle(
                  fontSize: MyFonts.size14,
                  color: AppColors.primary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- TRANSACTION TILE ----
  Widget _transactionTile(LoyaltyTransaction t) {
    double points = double.tryParse('${t.points}') ?? 0;
    bool isEarned = t.orderId != null ||
        (t.type ?? '').toLowerCase().contains('earn');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isEarned ? Colors.green : AppColors.error)
                  .withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEarned
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: isEarned ? Colors.green : AppColors.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.description ?? (isEarned ? 'Points Earned' : 'Points Redeemed'),
                  style: getSemiBoldStyle(
                    fontSize: MyFonts.size13,
                    color: AppColors.text,
                  ),
                ),
                if (t.orderId != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Order #${t.orderId}',
                    style: getRegularStyle(
                      fontSize: MyFonts.size11,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isEarned ? '+' : '-'}${points.toStringAsFixed(0)}',
            style: getBoldStyle(
              fontSize: MyFonts.size14,
              color: isEarned ? Colors.green : AppColors.error,
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
            'Your loyalty points activity will show up here',
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