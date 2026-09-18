import '/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '/core/theme/textfont_styles.dart';

enum StepState { done, current, pending }

class DeliveryTimeline extends StatelessWidget {
  const DeliveryTimeline({required this.hasArrived});

  final bool hasArrived;

  static const _labels = [
    'Order Received',
    'Preparing Your Meal',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final states = <StepState>[
      StepState.done,
      StepState.done,
      hasArrived ? StepState.done : StepState.current,
      hasArrived ? StepState.current : StepState.pending,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_labels.length, (i) {
        final isLast = i == _labels.length - 1;
        return _TimelineTile(
          label: _labels[i],
          state: states[i],
          showConnector: !isLast,
          connectorFilled: states[i] == StepState.done,
          isLast: isLast,
        );
      }),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.label,
    required this.state,
    required this.showConnector,
    required this.connectorFilled,
    required this.isLast,
  });

  final String label;
  final StepState state;
  final bool showConnector;
  final bool connectorFilled;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        state == StepState.pending ? AppColors.textColor2 : AppColors.textColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _StepDot(state: state),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: connectorFilled
                        ? AppColors.primary
                        : AppColors.containerColor4,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 26, top: 2),
            child: Text(
              label,
              style: state == StepState.current
                  ? getBoldStyle(fontSize: 16, color: AppColors.primary)
                  : getSemiBoldStyle(fontSize: 15, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.state});

  final StepState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case StepState.done:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 14, color: Colors.white),
        );
      case StepState.current:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bgColor,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      case StepState.pending:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.bgColor,
            border: Border.all(color: AppColors.containerColor4, width: 2),
          ),
        );
    }
  }
}
