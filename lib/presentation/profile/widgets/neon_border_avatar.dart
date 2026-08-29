import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/smart_image.dart';

class NeonBorderAvatar extends StatefulWidget {
  final String? imageUrl;
  final String fallbackText;
  final double size;

  const NeonBorderAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText = 'U',
    this.size = 100,
  });

  @override
  State<NeonBorderAvatar> createState() => _NeonBorderAvatarState();
}

class _NeonBorderAvatarState extends State<NeonBorderAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + 20,
      height: widget.size + 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _NeonPainter(
                  rotation: _controller.value * 2 * math.pi,
                  color: Colors.blueAccent,
                ),
                size: Size(widget.size + 15, widget.size + 15),
              );
            },
          ),
          _hasImage() ? _image() : _fallback(),
        ],
      ),
    );
  }

  bool _hasImage() {
    final url = widget.imageUrl;
    return url != null && url.isNotEmpty;
  }

  Widget _image() {
    return SmartImage(
      imagePath: widget.imageUrl!,
      width: widget.size,
      height: widget.size,
      borderRadius: BorderRadius.all(Radius.circular(widget.size / 2)),
      errorWidget: _fallback(),
      placeholder: _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A237E), Color(0xFF00897B)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.fallbackText.isEmpty ? 'U' : widget.fallbackText,
        style: TextStyle(
          color: Colors.white,
          fontSize: widget.size * 0.38,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NeonPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _NeonPainter({required this.rotation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color,
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final blurPaint = Paint()
      ..shader = paint.shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawArc(rect.deflate(2), 0, 2 * math.pi, false, blurPaint);
    canvas.drawArc(rect.deflate(2), 0, 2 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant _NeonPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
