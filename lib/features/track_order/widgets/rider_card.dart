import '/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '/core/theme/textfont_styles.dart';
import 'package:url_launcher/url_launcher.dart';

class RiderCard extends StatelessWidget {
  const RiderCard({
    super.key,
    required this.riderName,
    required this.riderPhoneNumber,
  });

  final String riderName;
  final String riderPhoneNumber;

  Future<void> _call() => launchUrl(Uri(scheme: 'tel', path: riderPhoneNumber));

  Future<void> _message() =>
      launchUrl(Uri(scheme: 'sms', path: riderPhoneNumber));

  @override
  Widget build(BuildContext context) {
    final bool hasPhone = riderPhoneNumber.isNotEmpty;
    final String displayName =
        riderName.isEmpty ? 'Assigning your rider…' : riderName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.containerColor4,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        // Top-aligned, not centered: once Message can drop to its own line
        // below (see the Wrap further down), a centered avatar would drift
        // off-center against the now-taller text column.
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // A tinted fill of its own, distinct from the card behind it in
              // both themes. Without this the circle was fully transparent,
              // so in dark mode — where the card and the page share the same
              // surface tone — the badge nearly disappeared, leaving only its
              // ring.
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child:
                Icon(Icons.person_outline, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: getBoldStyle(fontSize: 16, color: AppColors.textColor),
                ),
                const SizedBox(height: 8),
                if (hasPhone)
                  // Wrap, not Row: a plain Row has no fallback if "Call" and
                  // "Message" don't both fit on one line — a narrower phone
                  // or a larger system text size clips it. Wrap drops
                  // Message to its own line instead of overflowing.
                  Wrap(
                    spacing: 20,
                    runSpacing: 8,
                    children: [
                      _RiderAction(
                          icon: Icons.call, label: 'Call', onTap: _call),
                      _RiderAction(
                        icon: Icons.sms_outlined,
                        label: 'Message',
                        onTap: _message,
                      ),
                    ],
                  )
                else
                  Text(
                    'Your Rider',
                    style: getRegularStyle(
                        fontSize: 13, color: AppColors.textColor2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiderAction extends StatelessWidget {
  const _RiderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label,
                style: getBoldStyle(fontSize: 13, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
