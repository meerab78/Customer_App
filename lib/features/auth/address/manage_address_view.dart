import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';
import 'model/address_model.dart';
import 'view.dart';
import 'manager_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/fonts_manager.dart';
import '../../../core/theme/textfont_styles.dart';

class ManageAddressView extends StatefulWidget {
  const ManageAddressView({super.key});

  @override
  State<ManageAddressView> createState() => _ManageAddressViewState();
}

class _ManageAddressViewState extends State<ManageAddressView> {
  // 3 fixed types: Home / Flat / Office
  final List<Map<String, dynamic>> _types = [
    {
      "id": 3,
      "name": "Home",
      "icon": Icons.home_rounded,
    },
    {
      "id": 4,
      "name": "Flat",
      "icon": Icons.apartment_rounded,
    },
    {
      "id": 5,
      "name": "Office",
      "icon": Icons.work_rounded,
    },
  ];

  // Sirf jis address ko user select karega uska ID yahan save hoga
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller =
      context.read<AddressManagerController>();

      setState(() {
        selectedAddressId =
            controller.selectedAddress?.addressId;
      });
    });
  }

  // Us type ka saved address dhoondo
  CustomerAddress? _addressForType(
      AddressManagerController c,
      int typeId,
      ) {
    for (final a in c.addresses) {
      if (a.addressTypeId == typeId) {
        return a;
      }
    }

    return null;
  }

  // 3 fixed slots mein jo addresses dikh chuke hain unke IDs
  Set<String?> _shownAddressIds(AddressManagerController c) {
    final ids = <String?>{};

    for (final type in _types) {
      final a = _addressForType(
        c,
        type["id"],
      );

      if (a != null) {
        ids.add(a.addressId);
      }
    }

    return ids;
  }

  // 3 fixed slots ke ilawa jo extra addresses hain
  List<CustomerAddress> _otherAddresses(
      AddressManagerController c,
      ) {
    final shown = _shownAddressIds(c);

    return c.addresses
        .where((a) => !shown.contains(a.addressId))
        .toList();
  }

  // Pencil/Add dabane pe picker kholo
  Future<void> _openPicker({
    required int typeId,
    CustomerAddress? existing,
  }) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressView(
          pickerMode: true,
        ),
      ),
    );

    if (result == null) {
      return;
    }

    final controller =
    context.read<AddressManagerController>();

    final success = await controller.addEditAddress(
      addressId: existing?.addressId,
      addressTypeId: typeId,
      address1: result["address1"] ?? "",
      latitude: result["latitude"] ?? "",
      longitude: result["longitude"] ?? "",
      isDefault: existing?.isDefault ?? 0,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Address saved"
              : "Failed to save address",
        ),
      ),
    );
  }

  // + Add New Address
  Future<void> _openAddNew() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressView(
          pickerMode: true,
        ),
      ),
    );

    if (result == null) {
      return;
    }

    final controller =
    context.read<AddressManagerController>();

    final success = await controller.addEditAddress(
      addressId: null,
      addressTypeId: 3,
      address1: result["address1"] ?? "",
      latitude: result["latitude"] ?? "",
      longitude: result["longitude"] ?? "",
      isDefault: 0,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Address saved"
              : "Failed to save address",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        title: Text(
          'Manage Address',
          style: getExtraBoldStyle(
            fontSize: MyFonts.size22,
            color: AppColors.text,
          ),
        ),
      ),

      body: Consumer<AddressManagerController>(
        builder: (context, c, _) {
          if (c.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final otherAddresses = _otherAddresses(c);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              18,
              10,
              18,
              30,
            ),
            children: [
              Text(
                'Saved Addresses',
                style: getBoldStyle(
                  fontSize: MyFonts.size18,
                  color: AppColors.text,
                ),
              ),

              const SizedBox(height: 14),

              // Home / Flat / Office
              ..._types.map((type) {
                final existing =
                _addressForType(
                  c,
                  type["id"],
                );

                return _typeCard(
                  icon: type["icon"],
                  typeName: type["name"],
                  existing: existing,

                  onEdit: () => _openPicker(
                    typeId: type["id"],
                    existing: existing,
                  ),
                );
              }),

              // Other Addresses
              if (otherAddresses.isNotEmpty) ...[
                const SizedBox(height: 10),

                Text(
                  'Other Addresses',
                  style: getBoldStyle(
                    fontSize: MyFonts.size18,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 14),

                ...otherAddresses.map((a) {
                  return _typeCard(
                    icon: Icons.location_on_rounded,
                    typeName: a.typeName,
                    existing: a,

                    onEdit: () => _openPicker(
                      typeId: a.addressTypeId ?? 3,
                      existing: a,
                    ),
                  );
                }),
              ],

              // Add New Address button
              const SizedBox(height: 10),

              InkWell(
                onTap: _openAddNew,
                borderRadius: BorderRadius.circular(18),

                child: Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.primary,
                    ),
                  ),

                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.primary,
                      ),

                      const SizedBox(width: 12),

                      Text(
                        'Add New Address',
                        style: getSemiBoldStyle(
                          fontSize: MyFonts.size14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Address card
  Widget _typeCard({
    required IconData icon,
    required String typeName,
    required CustomerAddress? existing,
    required VoidCallback onEdit,
  }) {
    final hasAddress =
        existing != null &&
            existing.address1.isNotEmpty;

    // Sirf selected address par true hoga
    final isSelected =
        existing != null &&
            selectedAddressId == existing.addressId;

    return InkWell(
      // Sirf tab select ho jab address maujood ho
      onTap: hasAddress
          ? () {
        setState(() {
          selectedAddressId =
              existing!.addressId;
        });

        context
            .read<AddressManagerController>()
            .selectAddress(existing);

        // Checkout ko wapas bhejo
        Navigator.pop(
          context,
          existing,
        );
      }
          : null,

      borderRadius: BorderRadius.circular(18),

      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
        ),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.grey200,
          ),
        ),

        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Icon(
              icon,
              color: AppColors.primary,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Text(
                        typeName,
                        style: getBoldStyle(
                          fontSize: MyFonts.size15,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    hasAddress
                        ? existing.address1
                        : "Add $typeName address",

                    style: getRegularStyle(
                      fontSize: MyFonts.size13,

                      color: hasAddress
                          ? AppColors.text
                          : AppColors.greyText,
                    ),

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Sirf selected address par tick
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),

            // Edit / Add button
            IconButton(
              onPressed: onEdit,

              icon: Icon(
                hasAddress
                    ? Icons.edit_rounded
                    : Icons.add_circle_outline_rounded,

                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}