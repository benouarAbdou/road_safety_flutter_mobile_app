import 'package:flutter/material.dart';

class SpeedCircle extends StatefulWidget {
  final double width;
  final double speed;
  const SpeedCircle({super.key, required this.width, required this.speed});

  @override
  State<SpeedCircle> createState() => _SpeedCircleState();
}

class _SpeedCircleState extends State<SpeedCircle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.width,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.speed.toString(),
              style: TextStyle(
                fontSize: widget.width * 0.3,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text("km/h",
                style: TextStyle(
                  fontSize: widget.width * 0.15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ))
          ],
        ),
      ),
    );
  }
}
