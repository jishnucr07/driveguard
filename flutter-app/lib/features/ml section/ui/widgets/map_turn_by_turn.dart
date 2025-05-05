import 'package:driveguard/features/home/presentation/ui/turn_by_turn_nav_page.dart';
import 'package:driveguard/features/map/map_page.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapWidgetTurnByTurn extends StatefulWidget {
  final String destinationName;
  final LatLng destinationLocation;
  final double dh;
  const MapWidgetTurnByTurn(
      {super.key,
      required this.destinationName,
      required this.destinationLocation,
      required this.dh});

  @override
  State<MapWidgetTurnByTurn> createState() => _MapWidgetTurnByTurnState();
}

class _MapWidgetTurnByTurnState extends State<MapWidgetTurnByTurn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.dh * 0.4,
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
            child: NavigationApp(
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
                  builder: (context) => NavigationApp(
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
