
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

import '../../base/view.dart';

class AddressView extends StatefulWidget {
  // pickerMode = true  -> address module se khula hai, result return karega
  // pickerMode = false -> purana launch flow, BaseView pe jayega
  final bool pickerMode;

  const AddressView({super.key, this.pickerMode = false});

  @override
  State<AddressView> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressView> {
  static const CameraPosition initialPosition = CameraPosition(
    target: LatLng(31.5204, 74.3587),
    zoom: 14,
  );

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressController>().getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddressController>();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) async {
              provider.mapController = controller;
              if (provider.latitude != null && provider.longitude != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(provider.latitude!, provider.longitude!),
                    17,
                  ),
                );
              }
            },
            onCameraMoveStarted: () {
              provider.onMoveStarted();
            },
            onCameraMove: (CameraPosition position) {
              provider.latitude = position.target.latitude;
              provider.longitude = position.target.longitude;
            },
            onCameraIdle: () {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 400), () {
                provider.getAddressFromLatLng();
              });
            },
          ),

          // Fixed center pin — YEHI EKLOTA marker hai (Careem/Uber style)
          Center(
            child: IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_pin,
                    color: AppColors.primary,
                    size: 46,
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black26,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.softShadow08,
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: provider.searchController,
                      onChanged: provider.searchAddress,
                      style: getRegularStyle(
                        fontSize: MyFonts.size14,
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration(
                        hintText: "Search your location",
                        hintStyle: getRegularStyle(
                          fontSize: MyFonts.size14,
                          color: AppColors.greyText,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // SEARCH RESULTS LIST
                  if (provider.searchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.softShadow08,
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: provider.searchResults.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          indent: 56,
                          color: AppColors.grey200,
                        ),
                        itemBuilder: (context, index) {
                          final place = provider.searchResults[index];
                          return ListTile(
                            leading: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              place["description"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: getRegularStyle(
                                fontSize: MyFonts.size13,
                                color: AppColors.text,
                              ),
                            ),
                            onTap: () async {
                              await provider.selectPlace(place["place_id"]);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 270,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softShadow08,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FloatingActionButton(
                mini: true,
                elevation: 0,
                backgroundColor: AppColors.white,
                onPressed: () async {
                  await provider.getCurrentLocation();
                },
                child: Icon(
                  Icons.my_location_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 15,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softShadow08,
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag-handle style divider for visual polish
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Delivery location",
                              style: getSemiBoldStyle(
                                fontSize: MyFonts.size12,
                                color: AppColors.greyText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              provider.isLoading
                                  ? "Locating..."
                                  : (provider.selectedAddress.isEmpty
                                  ? "Select your delivery address"
                                  : provider.selectedAddress),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: getSemiBoldStyle(
                                fontSize: MyFonts.size14,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // House / Street / Landmark field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey100.withOpacity(0.6),
                      border: Border.all(color: AppColors.grey200),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: provider.addressDetailController,
                      maxLines: 2,
                      style: getRegularStyle(
                        fontSize: MyFonts.size13,
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration(
                        hintText: "House/Flat No, Street, Landmark (optional)",
                        hintStyle: getRegularStyle(
                          fontSize: MyFonts.size13,
                          color: AppColors.greyText,
                        ),
                        prefixIcon: Icon(
                          Icons.home_outlined,
                          color: AppColors.greyText,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // CONTINUE / CONFIRM BUTTON (hamesha dikhega)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.grey300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: provider.selectedAddress.isEmpty
                          ? null
                          : () async {
                        if (widget.pickerMode) {
                          final extraDetail =
                          provider.addressDetailController.text.trim();
                          final fullAddress = extraDetail.isNotEmpty
                              ? "$extraDetail, ${provider.selectedAddress}"
                              : provider.selectedAddress;

                          Navigator.pop(context, {
                            "address1": fullAddress,
                            "latitude":
                            provider.latitude?.toString() ?? "",
                            "longitude":
                            provider.longitude?.toString() ?? "",
                          });
                        }
                        else {
                          await provider.saveAddress();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BaseView()),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.pickerMode
                                ? "Confirm Location"
                                : "Continue",
                            style: getBoldStyle(
                                color: AppColors.white,
                                fontSize: MyFonts.size16),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.white,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
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