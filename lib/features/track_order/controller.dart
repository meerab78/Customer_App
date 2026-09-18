import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constant/app_constants.dart';
import '../../generated/assets.dart';
import '/core/theme/app_colors.dart';
import 'model.dart';
import 'repository.dart';

/// Live order tracking.
///
/// Directions is asked for the road once per trip (rider→destination on the
/// first fix). Every poll after that costs nothing on the Google side: the
/// reported fix is snapped onto the cached road and the marker is animated
/// along that road from where it is drawn to that point over roughly one poll
/// interval, so a long hop plays fast and a short one plays slow.
///
/// The marker is never moved off a road. When a fix lands away from the
/// cached road the marker holds position and one Directions call fetches a
/// new road that starts at the marker, passes through the fix and ends at the
/// destination, so the marker drives onto the new road instead of cutting
/// across open ground. Only the road still ahead of the marker is drawn.
class OrderTrackingController extends ChangeNotifier {
  OrderTrackingController();

  final OrderTrackingRepository _repository = OrderTrackingRepository();

  /// How often the tracking endpoint is polled.
  static const Duration pollInterval = Duration(seconds: 5);

  /// One hop is played over a little less than a poll so the marker has
  /// settled when the next fix arrives. Fixed duration is what makes speed
  /// scale with distance.
  static const Duration _legDuration = Duration(milliseconds: 4500);
  static const Duration _frame = Duration(milliseconds: 40);

  /// A fix further than this from the cached road counts as off-route.
  static const double _offRouteMeters = 50;

  /// Re-routes are never requested more often than this.
  static const Duration _minRerouteGap = Duration(seconds: 20);

  /// Within this range of the destination a fix is never treated as
  /// off-route: the rider is walking up to the door / inside a compound, and
  /// re-routing there would burn a request every cycle for nothing.
  static const double _nearDestinationMeters = 150;

  /// Below this the hop is GPS jitter and is not animated at all; above the
  /// teleport distance it is a data gap and the marker just jumps.
  static const double _jitterMeters = 2;
  static const double _teleportMeters = 1500;

  // Screen state
  bool _isLoading = true;
  bool _isOrderTrackingAvailable = false;
  String _timeToDeliver = '';
  String _riderName = '';
  String _riderPhoneNumber = '';
  bool _hasArrived = false;
  bool _showArrivalDialog = false;

  // Map state
  LatLng? _startLatLng;
  LatLng? _currentLatLng; // last fix reported by the backend
  LatLng? _endLatLng;
  LatLng? _displayedLatLng; // where the rider marker is drawn right now
  bool _facingEast = true;
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  /// Bumped whenever markers/polylines/circles change. The map listens to
  /// this alone, so animation frames never rebuild the rest of the page.
  final ValueNotifier<int> mapRevision = ValueNotifier<int>(0);

  // Cached road
  List<LatLng> _route = []; // road the marker follows, ending at the destination
  bool _bootstrapped = false;
  bool _bootstrapping = false;
  bool _routeInFlight = false;
  DateTime? _lastRouteFetch;

  // Marker icons, loaded once
  BitmapDescriptor? _storeIcon;
  BitmapDescriptor? _destinationIcon;
  BitmapDescriptor? _riderRightIcon;
  BitmapDescriptor? _riderLeftIcon;

  // Animation
  Timer? _apiRefreshTimer;
  Timer? _animTimer;
  List<LatLng> _legPath = [];
  List<double> _legCumulative = [];
  double _legTotal = 0;
  DateTime? _legStart;
  int _legTicks = 0;
  bool _disposed = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isOrderTrackingAvailable => _isOrderTrackingAvailable;
  String get timeToDeliver => _timeToDeliver;
  String get riderName => _riderName;
  String get riderPhoneNumber => _riderPhoneNumber;
  bool get showArrivalDialog => _showArrivalDialog;

  /// True once the rider is within arrival range of the destination — the
  /// same signal that fires the one-time arrival dialog, exposed here so the
  /// page can reflect "delivered" in its own status chip and timeline too.
  bool get hasArrived => _hasArrived;

  /// Last fix reported by the backend (the marker may still be driving to it).
  LatLng? get riderLatLng => _currentLatLng;
  LatLng? get endLatLng => _endLatLng;
  Set<Polyline> get polylines => _polylines;
  Set<Marker> get markers => _markers;
  Set<Circle> get circles => _circles;

  // -----------------------------
  // LIFECYCLE & INITIALIZATION
  // -----------------------------

  void initialize(String orderId) {
    _fetchOrderTrackingData(orderId);
    _apiRefreshTimer = Timer.periodic(pollInterval, (timer) {
      _fetchOrderTrackingData(orderId);
    });
  }

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    // The layers are already built; only the camera needs to catch up.
    if (_bootstrapped) {
      _fitCamera(force: true);
      mapRevision.value++;
    }
  }

  void dialogShown() {
    _showArrivalDialog = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    _apiRefreshTimer?.cancel();
    _animTimer?.cancel();
    _mapController?.dispose();
    mapRevision.dispose();
    super.dispose();
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  // -----------------------------
  // API & DATA LOGIC
  // -----------------------------

  Future<void> _fetchOrderTrackingData(String orderId) async {
    try {
      final response = await _repository.getOrderTracking(orderId);
      if (_disposed) return;

      if (response != null) {
        final trackingResponse = OrderTrackingResponse.fromJson(response);

        if (trackingResponse.success == true && trackingResponse.data != null) {
          await _applyApiData(trackingResponse.data!);
        } else {
          _setUnavailable();
        }
      } else {
        _setUnavailable();
      }
    } catch (e) {
      debugPrint("Error fetching tracking data: $e");
      _setUnavailable();
    }
  }

  void _setUnavailable() {
    _isLoading = false;
    _isOrderTrackingAvailable = false;
    _notify();
  }

  Future<void> _applyApiData(Data data) async {
    final double? startLat = double.tryParse(data.startLatitude ?? '');
    final double? startLng = double.tryParse(data.startLongitude ?? '');
    final double? currentLat = double.tryParse(data.currentLatitude ?? '');
    final double? currentLng = double.tryParse(data.currentLongitude ?? '');
    final double? endLat = double.tryParse(data.endLatitude ?? '');
    final double? endLng = double.tryParse(data.endLongitude ?? '');

    if (startLat == null ||
        startLng == null ||
        currentLat == null ||
        currentLng == null ||
        endLat == null ||
        endLng == null) {
      _setUnavailable();
      return;
    }

    final LatLng start = LatLng(startLat, startLng);
    final LatLng reported = LatLng(currentLat, currentLng);
    final LatLng end = LatLng(endLat, endLng);

    _riderName = data.riderName ?? '';
    _riderPhoneNumber = data.riderContactno ?? '';

    if (!_bootstrapped) {
      // A slow first fetch can overlap the next poll; let the first one win.
      if (_bootstrapping) return;
      _bootstrapping = true;

      _startLatLng = start;
      _endLatLng = end;
      _currentLatLng = reported;

      await _ensureIcons();
      await _loadInitialRoute(reported, end);
      if (_disposed) return;

      final _RouteFix? fix = _project(reported, _route);
      _displayedLatLng =
          fix != null && fix.offsetMeters <= _offRouteMeters ? fix.point : reported;
      _updateFacing(_displayedLatLng!, end);

      _bootstrapped = true;
      _bootstrapping = false;
      _isOrderTrackingAvailable = true;
      _isLoading = false;

      _rebuildLayers();
      _fitCamera(force: true);
      _notify();
      return;
    }

    _currentLatLng = reported;
    _endLatLng = end;
    _isOrderTrackingAvailable = true;
    _isLoading = false;
    _notify();

    _onNewFix(reported);
  }

  // -----------------------------
  // ROUTE CACHE
  // -----------------------------

  /// First fix: one Directions call for the road ahead (rider→destination).
  /// Only if Directions itself fails does the route fall back to a straight
  /// line; there is nothing better to draw in that case.
  Future<void> _loadInitialRoute(LatLng rider, LatLng end) async {
    _routeInFlight = true;
    _route = await _routeBetween(origin: rider, destination: end) ??
        <LatLng>[rider, end];
    _routeInFlight = false;
    _lastRouteFetch = DateTime.now();
  }

  /// The rider is off the cached road. One Directions call fetches a road
  /// that starts where the marker is drawn (already on a road), passes
  /// through the reported fix and ends at the destination. The marker then
  /// drives onto the new road along asphalt the whole way. Rate limited to
  /// one call per [_minRerouteGap]; until the road lands the marker holds.
  /// A single `via:` point keeps the request in the basic Directions tier.
  Future<void> _maybeReroute(LatLng reported) async {
    if (_routeInFlight) return;
    final DateTime? last = _lastRouteFetch;
    if (last != null && DateTime.now().difference(last) < _minRerouteGap) {
      return;
    }
    final LatLng? end = _endLatLng;
    if (end == null) return;
    final LatLng origin = _displayedLatLng ?? reported;

    _routeInFlight = true;
    final List<LatLng>? fresh = await _routeBetween(
      origin: origin,
      via: reported,
      destination: end,
    );
    _routeInFlight = false;
    _lastRouteFetch = DateTime.now();
    // On failure keep the old road rather than drawing a straight line.
    if (_disposed || fresh == null) return;

    _route = fresh;
    _rebuildLayers();
    final LatLng? latest = _currentLatLng;
    if (latest != null) _onNewFix(latest);
  }

  Future<List<LatLng>?> _routeBetween({
    required LatLng origin,
    required LatLng destination,
    LatLng? via,
  }) async {
    try {
      final polylinePoints = PolylinePoints(apiKey: AppConstants.kPlacesApiKey);
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
          wayPoints: [
            if (via != null)
              PolylineWayPoint(
                location: '${via.latitude},${via.longitude}',
                stopOver: false,
              ),
          ],
        ),
      );
      if (result.points.isNotEmpty) {
        return result.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
    return null;
  }

  // -----------------------------
  // MOVEMENT
  // -----------------------------

  void _onNewFix(LatLng reported) {
    final LatLng? end = _endLatLng;
    final LatLng from = _displayedLatLng ?? reported;
    final _RouteFix? fix = _project(reported, _route);
    if (fix == null) return;

    final bool nearDestination =
        end != null && _meters(reported, end) <= _nearDestinationMeters;
    if (fix.offsetMeters > _offRouteMeters && !nearDestination) {
      // Off the known road: hold the marker where it is and get a new road.
      _maybeReroute(reported);
      return;
    }

    // The marker only ever goes to a point on the road.
    final LatLng target = fix.point;
    if (_meters(from, target) < _jitterMeters) return;

    // Travel along the road, forwards or (GPS noise) backwards. A straight
    // hop is only possible right after a failed first route, where the
    // "road" is already the straight fallback line.
    final _RouteFix? fromFix = _project(from, _route);
    final List<LatLng> path;
    if (fromFix == null || fromFix.offsetMeters > _offRouteMeters) {
      path = [from, target];
    } else if (fix.index >= fromFix.index) {
      path = [
        from,
        ..._route.sublist(fromFix.index + 1, fix.index + 1),
        target,
      ];
    } else {
      path = [
        from,
        ..._route.sublist(fix.index + 1, fromFix.index + 1).reversed,
        target,
      ];
    }

    _startLeg(path);
  }

  void _startLeg(List<LatLng> path) {
    _animTimer?.cancel();
    _animTimer = null;

    _legPath = path;
    _legCumulative = [0];
    for (int i = 1; i < path.length; i++) {
      _legCumulative.add(_legCumulative.last + _meters(path[i - 1], path[i]));
    }
    _legTotal = _legCumulative.last;

    if (_legTotal > _teleportMeters) {
      _updateFacing(path.first, path.last);
      _displayedLatLng = path.last;
      _rebuildLayers();
      _fitCamera();
      return;
    }

    _legStart = DateTime.now();
    _legTicks = 0;
    _animTimer = Timer.periodic(_frame, _tick);
  }

  void _tick(Timer timer) {
    if (_disposed) {
      timer.cancel();
      return;
    }
    final DateTime? started = _legStart;
    if (started == null || _legPath.length < 2) {
      timer.cancel();
      return;
    }

    final int elapsedMs = DateTime.now().difference(started).inMilliseconds;
    final double fraction =
        (elapsedMs / _legDuration.inMilliseconds).clamp(0.0, 1.0);
    final double travelled = _legTotal * fraction;

    int seg = 1;
    while (seg < _legCumulative.length - 1 && _legCumulative[seg] < travelled) {
      seg++;
    }
    final LatLng a = _legPath[seg - 1];
    final LatLng b = _legPath[seg];
    final double segLen = _legCumulative[seg] - _legCumulative[seg - 1];
    final double t = segLen == 0
        ? 1.0
        : ((travelled - _legCumulative[seg - 1]) / segLen).clamp(0.0, 1.0);

    _displayedLatLng = LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
    _updateFacing(a, b);

    _legTicks++;
    final bool done = fraction >= 1;
    // The line split is rebuilt every few frames only: each polyline update
    // ships its whole point list over the platform channel.
    _rebuildLayers(polylines: done || _legTicks % 4 == 0);

    if (done) {
      timer.cancel();
      _animTimer = null;
      _fitCamera();
    }
  }

  /// Sprite side is chosen from the direction of travel with a dead zone, so
  /// a road running due north/south does not make the bike flip back and
  /// forth every frame.
  void _updateFacing(LatLng from, LatLng to) {
    final double dLng = to.longitude - from.longitude;
    if (dLng.abs() < 1e-6) return;
    _facingEast = dLng > 0;
  }

  // -----------------------------
  // MAP LAYERS
  // -----------------------------

  Future<void> _ensureIcons() async {
    if (_storeIcon != null) return;
    const ImageConfiguration config = ImageConfiguration(devicePixelRatio: 3.0);
    _storeIcon =
        await BitmapDescriptor.fromAssetImage(config, Assets.images.store.path);
    _destinationIcon = await BitmapDescriptor.fromAssetImage(
        config, Assets.images.destination.path);
    _riderRightIcon = await BitmapDescriptor.fromAssetImage(
        config, Assets.images.riderRight.path);
    _riderLeftIcon = await BitmapDescriptor.fromAssetImage(
        config, Assets.images.riderLeft.path);
  }

  void _rebuildLayers({bool polylines = true}) {
    final LatLng? start = _startLatLng;
    final LatLng? pos = _displayedLatLng;
    final LatLng? end = _endLatLng;
    if (start == null || pos == null || end == null) return;

    _markers = {
      Marker(
        markerId: const MarkerId('Start'),
        position: start,
        anchor: const Offset(0.5, 0.5),
        icon: _storeIcon ?? BitmapDescriptor.defaultMarker,
      ),
      Marker(
        markerId: const MarkerId('Current'),
        position: pos,
        anchor: const Offset(0.5, 0.5),
        icon: (_facingEast ? _riderRightIcon : _riderLeftIcon) ??
            BitmapDescriptor.defaultMarker,
      ),
      Marker(
        markerId: const MarkerId('End'),
        position: end,
        anchor: const Offset(0.5, 0.5),
        icon: _destinationIcon ?? BitmapDescriptor.defaultMarker,
      ),
    };

    // A soft halo around the rider's live position
    _circles = {
      Circle(
        circleId: const CircleId('riderHalo'),
        center: pos,
        radius: 45,
        fillColor: AppColors.primary.withValues(alpha: 0.16),
        strokeColor: AppColors.primary.withValues(alpha: 0.4),
        strokeWidth: 1,
      ),
    };

    if (polylines) _rebuildPolylines(pos);

    if (!_disposed) mapRevision.value++;
  }

  /// Draws only the road still ahead of the marker. The part already driven
  /// is not shown at all.
  void _rebuildPolylines(LatLng pos) {
    final _RouteFix? fix = _project(pos, _route);
    final List<LatLng> remaining = fix == null
        ? [pos, if (_endLatLng != null) _endLatLng!]
        : [pos, ..._route.sublist(fix.index + 1)];

    _polylines = {
      Polyline(
        polylineId: const PolylineId('remaining'),
        color: AppColors.primary,
        width: 6,
        points: remaining,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  /// Fits rider + destination on the first fix, and afterwards only when the
  /// rider has left the visible area, so the camera stops lurching on every
  /// poll and stops fighting the user on the expanded map.
  Future<void> _fitCamera({bool force = false}) async {
    final GoogleMapController? map = _mapController;
    final LatLng? pos = _displayedLatLng;
    final LatLng? end = _endLatLng;
    if (map == null || pos == null || end == null) return;

    if (!force) {
      try {
        final LatLngBounds visible = await map.getVisibleRegion();
        if (visible.contains(pos)) return;
      } catch (_) {
        // Map not laid out yet; fall through and fit.
      }
    }
    if (_disposed) return;

    final LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(pos.latitude, end.latitude),
        min(pos.longitude, end.longitude),
      ),
      northeast: LatLng(
        max(pos.latitude, end.latitude),
        max(pos.longitude, end.longitude),
      ),
    );
    try {
      await map.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (e) {
      debugPrint('Error moving camera: $e');
    }
  }

  // -----------------------------
  // GEOMETRY
  // -----------------------------

  /// Nearest point on [route] to [p]: which segment it lies on, the point
  /// itself and how far [p] is from it.
  _RouteFix? _project(LatLng p, List<LatLng> route) {
    if (route.isEmpty) return null;
    if (route.length == 1) {
      return _RouteFix(0, route.first, _meters(p, route.first));
    }

    // Local flat projection: longitude scaled by cos(lat) so distances along
    // both axes are comparable.
    final double k = cos(_deg2rad(p.latitude));
    final double px = p.longitude * k;
    final double py = p.latitude;

    double bestOffset = double.infinity;
    int bestIndex = 0;
    LatLng bestPoint = route.first;

    for (int i = 0; i < route.length - 1; i++) {
      final LatLng a = route[i];
      final LatLng b = route[i + 1];
      final double ax = a.longitude * k, ay = a.latitude;
      final double bx = b.longitude * k, by = b.latitude;
      final double dx = bx - ax, dy = by - ay;
      final double len2 = dx * dx + dy * dy;
      double t = len2 == 0 ? 0 : ((px - ax) * dx + (py - ay) * dy) / len2;
      t = t.clamp(0.0, 1.0);
      final LatLng q = LatLng(
        a.latitude + (b.latitude - a.latitude) * t,
        a.longitude + (b.longitude - a.longitude) * t,
      );
      final double d = _meters(p, q);
      if (d < bestOffset) {
        bestOffset = d;
        bestIndex = i;
        bestPoint = q;
      }
    }
    return _RouteFix(bestIndex, bestPoint, bestOffset);
  }

  double _meters(LatLng a, LatLng b) {
    const double earthRadius = 6371000;
    final double dLat = _deg2rad(b.latitude - a.latitude);
    final double dLon = _deg2rad(b.longitude - a.longitude);
    final double h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(a.latitude)) *
            cos(_deg2rad(b.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return earthRadius * 2 * asin(sqrt(h));
  }

  double _deg2rad(double deg) => deg * (pi / 180);
}

class _RouteFix {
  const _RouteFix(this.index, this.point, this.offsetMeters);

  /// Index of the route segment start the point lies on.
  final int index;
  final LatLng point;
  final double offsetMeters;
}
