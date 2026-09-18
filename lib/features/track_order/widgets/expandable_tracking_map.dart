import '/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '/features/track_order/controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExpandableTrackingMap extends StatefulWidget {
  const ExpandableTrackingMap({required this.controller, required this.onBack});

  final OrderTrackingController controller;
  final VoidCallback onBack;

  static const double _collapsedHeight = 300;

  @override
  State<ExpandableTrackingMap> createState() => _ExpandableTrackingMapState();
}

class _ExpandableTrackingMapState extends State<ExpandableTrackingMap> {
  bool _expanded = false;

  void _setExpanded(bool value) {
    if (_expanded == value) return;
    setState(() => _expanded = value);
  }

  @override
  Widget build(BuildContext context) {
    final double expandedHeight =
        (MediaQuery.sizeOf(context).height * 0.62).clamp(420.0, 640.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      height:
          _expanded ? expandedHeight : ExpandableTrackingMap._collapsedHeight,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _expanded ? null : () => _setExpanded(true),
              // The rider marker animates at ~25 fps between fixes. Listening
              // to mapRevision here means only the map re-renders per frame,
              // not the whole tracking page.
              child: ValueListenableBuilder<int>(
                valueListenable: widget.controller.mapRevision,
                builder: (context, _, __) {
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: widget.controller.endLatLng ?? const LatLng(0, 0),
                      zoom: 14,
                    ),
                    onMapCreated: widget.controller.setMapController,
                    polylines: widget.controller.polylines,
                    markers: widget.controller.markers,
                    circles: widget.controller.circles,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    scrollGesturesEnabled: _expanded,
                    zoomGesturesEnabled: _expanded,
                    rotateGesturesEnabled: _expanded,
                    tiltGesturesEnabled: _expanded,
                  );
                },
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 12,
              left: 16,
              child: _MapIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                iconSize: 18,
                onTap: widget.onBack,
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: _MapIconButton(
                icon: _expanded
                    ? Icons.close_fullscreen_rounded
                    : Icons.open_in_full_rounded,
                onTap: () => _setExpanded(!_expanded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.icon,
    required this.onTap,
    this.iconSize = 16,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardColor.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: iconSize, color: AppColors.textColor),
        ),
      ),
    );
  }
}
