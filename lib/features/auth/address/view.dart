// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'controller.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/fonts_manager.dart';
// import '../../../core/theme/textfont_styles.dart';
//
// import '../../base/view.dart';
//
// class AddressView extends StatefulWidget {
//   // pickerMode = true  -> address module se khula hai, result return karega
//   // pickerMode = false -> purana launch flow, BaseView pe jayega
//   final bool pickerMode;
//
//   const AddressView({super.key, this.pickerMode = false});
//
//   @override
//   State<AddressView> createState() => _AddressScreenState();
// }
//
// class _AddressScreenState extends State<AddressView> {
//   static const CameraPosition initialPosition = CameraPosition(
//     target: LatLng(31.5204, 74.3587),
//     zoom: 14,
//   );
//
//   Timer? _debounce;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<AddressController>().getCurrentLocation();
//     });
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AddressController>();
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: initialPosition,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: false,
//             zoomControlsEnabled: false,
//             compassEnabled: true,
//             onMapCreated: (controller) async {
//               provider.mapController = controller;
//               if (provider.latitude != null && provider.longitude != null) {
//                 controller.animateCamera(
//                   CameraUpdate.newLatLngZoom(
//                     LatLng(provider.latitude!, provider.longitude!),
//                     17,
//                   ),
//                 );
//               }
//             },
//             onCameraMoveStarted: () {
//               provider.onMoveStarted();
//             },
//             onCameraMove: (CameraPosition position) {
//               provider.latitude = position.target.latitude;
//               provider.longitude = position.target.longitude;
//             },
//             onCameraIdle: () {
//               _debounce?.cancel();
//               _debounce = Timer(const Duration(milliseconds: 400), () {
//                 provider.getAddressFromLatLng();
//               });
//             },
//           ),
//
//           // Fixed center pin — YEHI EKLOTA marker hai (Careem/Uber style)
//           const Center(
//             child: IgnorePointer(
//               child: Icon(
//                 Icons.location_pin,
//                 color: AppColors.red,
//                 size: 45,
//               ),
//             ),
//           ),
//
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.white,
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: const [
//                         BoxShadow(color: AppColors.black26, blurRadius: 12)
//                       ],
//                     ),
//                     child: TextField(
//                       controller: provider.searchController,
//                       onChanged: provider.searchAddress,
//                       decoration: const InputDecoration(
//                         hintText: "Search your location",
//                         prefixIcon: Icon(Icons.search),
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(vertical: 16),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 10),
//
//                 ],
//               ),
//             ),
//           ),
//
//           Positioned(
//             right: 16,
//             bottom: 260,
//             child: FloatingActionButton(
//               mini: true,
//               backgroundColor: AppColors.white,
//               onPressed: () async {
//                 await provider.getCurrentLocation();
//               },
//               child: const Icon(Icons.my_location, color: AppColors.black),
//             ),
//           ),
//
//           Positioned(
//             left: 12,
//             right: 12,
//             bottom: 15,
//             child: Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: AppColors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: const [
//                   BoxShadow(color: AppColors.black26, blurRadius: 15)
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, color: AppColors.red),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           provider.isLoading
//                               ? "Locating..."
//                               : (provider.selectedAddress.isEmpty
//                               ? "Select your delivery address"
//                               : provider.selectedAddress),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // House / Street / Landmark field
//                   Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.white,
//                       border: Border.all(color: AppColors.black26),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: TextField(
//                       controller: provider.addressDetailController,
//                       maxLines: 2,
//                       decoration: const InputDecoration(
//                         hintText: "House/Flat No, Street, Landmark (optional)",
//                         prefixIcon: Icon(Icons.home_outlined),
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   if (provider.searchResults.isEmpty)
//                     SizedBox(
//                       width: double.infinity,
//                       height: 52,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.black,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         onPressed: provider.selectedAddress.isEmpty
//                             ? null
//                             : () async {
//                           if (widget.pickerMode) {
//                             final extraDetail =
//                             provider.addressDetailController.text.trim();
//                             final fullAddress = extraDetail.isNotEmpty
//                                 ? "$extraDetail, ${provider.selectedAddress}"
//                                 : provider.selectedAddress;
//
//                             Navigator.pop(context, {
//                               "address1": fullAddress,
//                               "latitude": provider.latitude?.toString() ?? "",
//                               "longitude": provider.longitude?.toString() ?? "",
//                             });
//                           } else {
//                             await provider.saveAddress();
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(builder: (_) => const BaseView()),
//                             );
//                           }
//                         },
//                         child: Text(
//                           widget.pickerMode ? "Confirm Location" : "Continue",
//                           style: getBoldStyle(color: AppColors.white, fontSize: MyFonts.size16),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
          const Center(
            child: IgnorePointer(
              child: Icon(
                Icons.location_pin,
                color: AppColors.red,
                size: 45,
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: AppColors.black26, blurRadius: 12)
                      ],
                    ),
                    child: TextField(
                      controller: provider.searchController,
                      onChanged: provider.searchAddress,
                      decoration: const InputDecoration(
                        hintText: "Search your location",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // SEARCH RESULTS LIST
                  if (provider.searchResults.isNotEmpty)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(color: AppColors.black26, blurRadius: 10)
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: provider.searchResults.length,
                        itemBuilder: (context, index) {
                          final place = provider.searchResults[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on,
                                color: AppColors.red),
                            title: Text(
                              place["description"],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
            bottom: 260,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.white,
              onPressed: () async {
                await provider.getCurrentLocation();
              },
              child: const Icon(Icons.my_location, color: AppColors.black),
            ),
          ),

          Positioned(
            left: 12,
            right: 12,
            bottom: 15,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: AppColors.black26, blurRadius: 15)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          provider.isLoading
                              ? "Locating..."
                              : (provider.selectedAddress.isEmpty
                              ? "Select your delivery address"
                              : provider.selectedAddress),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // House / Street / Landmark field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.black26),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: provider.addressDetailController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "House/Flat No, Street, Landmark (optional)",
                        prefixIcon: Icon(Icons.home_outlined),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CONTINUE / CONFIRM BUTTON (hamesha dikhega)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
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
                        } else {
                          await provider.saveAddress();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BaseView()),
                          );
                        }
                      },
                      child: Text(
                        widget.pickerMode ? "Confirm Location" : "Continue",
                        style: getBoldStyle(
                            color: AppColors.white, fontSize: MyFonts.size16),
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