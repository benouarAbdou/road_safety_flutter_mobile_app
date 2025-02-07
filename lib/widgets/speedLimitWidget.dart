import 'package:flutter/material.dart';

class SpeedLimitCircle extends StatefulWidget {
  final double width;
  final int speedLimit;

  const SpeedLimitCircle({
    super.key,
    required this.width,
    required this.speedLimit,
  });

  @override
  State<SpeedLimitCircle> createState() => _SpeedLimitCircleState();
}

class _SpeedLimitCircleState extends State<SpeedLimitCircle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.redAccent,
          width: widget.width * 0.12,
        ),
      ),
      child: Center(
        child: Text(
          widget.speedLimit == 0 ? "N/A" : widget.speedLimit.toString(),
          style: TextStyle(
            fontSize: widget.width * 0.3,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
