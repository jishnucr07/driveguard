import 'package:driveguard/features/map/map_page.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapWidgetNotNav extends StatefulWidget {
  final String destinationName;
  final LatLng destinationLocation;
  final double dh;
  const MapWidgetNotNav(
      {super.key,
      required this.destinationName,
      required this.destinationLocation,
      required this.dh});

  @override
  State<MapWidgetNotNav> createState() => _MapWidgetNotNavState();
}

class _MapWidgetNotNavState extends State<MapWidgetNotNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.dh * 0.27,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ) // Shadow for elevation
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: OSMMapPage(
              destinationName: widget.destinationName,
              destinationLocation: widget.destinationLocation,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              color: Colors.white,
              icon: Icon(
                Icons.fullscreen,
                color: Colors.black,
                size: 40,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OSMMapPage(
                    destinationName: widget.destinationName,
                    destinationLocation: widget.destinationLocation,
                  ),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
