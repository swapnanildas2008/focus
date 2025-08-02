import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TreeWidget extends StatefulWidget {
  final double progress;
  final bool isGrowing;

  const TreeWidget({
    Key? key,
    required this.progress,
    this.isGrowing = false,
  }) : super(key: key);

  @override
  State<TreeWidget> createState() => _TreeWidgetState();
}

class _TreeWidgetState extends State<TreeWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isGrowing) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGrowing && !oldWidget.isGrowing) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isGrowing && oldWidget.isGrowing) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isGrowing ? _scaleAnimation.value : 1.0,
          child: CustomPaint(
            size: const Size(200, 250),
            painter: TreePainter(progress: widget.progress),
          ),
        );
      },
    );
  }
}

class TreePainter extends CustomPainter {
  final double progress;

  TreePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint trunkPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;

    final Paint leavesPaint = Paint()
      ..color = progress > 0.7 
          ? AppColors.forestGreen.shade500 
          : AppColors.forestGreen.shade300
      ..style = PaintingStyle.fill;

    final Paint flowerPaint = Paint()
      ..color = AppColors.accentPink
      ..style = PaintingStyle.fill;

    // Draw trunk
    final double trunkHeight = size.height * 0.4 * progress;
    final double trunkWidth = size.width * 0.1;
    
    canvas.drawRect(
      Rect.fromLTWH(
        size.width / 2 - trunkWidth / 2,
        size.height - trunkHeight,
        trunkWidth,
        trunkHeight,
      ),
      trunkPaint,
    );

    // Draw leaves if progress > 0.3
    if (progress > 0.3) {
      final double leavesRadius = size.width * 0.3 * (progress - 0.3) / 0.7;
      
      // Main crown
      canvas.drawCircle(
        Offset(size.width / 2, size.height - trunkHeight),
        leavesRadius,
        leavesPaint,
      );

      // Side crowns for fuller look
      if (progress > 0.6) {
        canvas.drawCircle(
          Offset(size.width / 2 - leavesRadius * 0.6, size.height - trunkHeight + leavesRadius * 0.3),
          leavesRadius * 0.7,
          leavesPaint,
        );
        canvas.drawCircle(
          Offset(size.width / 2 + leavesRadius * 0.6, size.height - trunkHeight + leavesRadius * 0.3),
          leavesRadius * 0.7,
          leavesPaint,
        );
      }

      // Add flowers when fully grown
      if (progress >= 1.0) {
        for (int i = 0; i < 5; i++) {
          final double angle = (i * 2 * 3.14159) / 5;
          final double flowerX = size.width / 2 + (leavesRadius * 0.8) * (i % 2 == 0 ? 1 : -1) * 0.5;
          final double flowerY = size.height - trunkHeight - leavesRadius * 0.5;
          
          canvas.drawCircle(
            Offset(flowerX, flowerY),
            3,
            flowerPaint,
          );
        }
      }
    }

    // Draw seed/sprout if progress < 0.3
    if (progress <= 0.3 && progress > 0) {
      final Paint seedPaint = Paint()
        ..color = AppColors.forestGreen.shade200
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(size.width / 2, size.height - 5),
        5 * progress / 0.3,
        seedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
