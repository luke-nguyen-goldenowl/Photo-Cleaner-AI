import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myapp/src/features/dashboard/place/helper/place_helpers.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import '../../logic/place_bloc.dart';
import '../../model/image_location.dart';

class XImageDetailSheet extends StatelessWidget {
  final MImageLocation imageLocation;
  final VoidCallback onZoomTo;

  const XImageDetailSheet({
    super.key,
    required this.imageLocation,
    required this.onZoomTo,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.file(
                      File(imageLocation.imagePath),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            icon: Icons.my_location,
                            label: S.of(context).common_latitude,
                            value: PlaceHelpers.toDMS(imageLocation.latitude),
                          ),
                          _buildInfoRow(
                            icon: Icons.location_on,
                            label: S.of(context).common_longtitude,
                            value: PlaceHelpers.toDMS(imageLocation.longitude,
                                isLat: false),
                          ),
                          if (imageLocation.dateTime != null)
                            _buildInfoRow(
                              icon: Icons.calendar_today,
                              label: S.of(context).common_time,
                              value: DateFormat('dd/MM/yyyy - HH:mm')
                                  .format(imageLocation.dateTime!),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context,
    MImageLocation imageLocation,
    VoidCallback onZoomTo,
  ) {
    context.read<PlaceBloc>().selectImage(imageLocation);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => XImageDetailSheet(
        imageLocation: imageLocation,
        onZoomTo: onZoomTo,
      ),
    ).then((_) {
      context.read<PlaceBloc>().clearSelection();
    });
  }
}

Widget _buildInfoRow(
    {required IconData icon, required String label, required String value}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Icon(icon, size: 25, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
