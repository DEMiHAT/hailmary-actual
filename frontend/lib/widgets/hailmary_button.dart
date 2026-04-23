
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HailMaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final double size;

  const HailMaryButton({
    super.key,
    required this.onPressed,
    this.size = 180,
  });

  @override
  State<HailMaryButton> createState() => _HailMaryButtonState();
}

class _HailMaryButtonState extends State<HailMaryButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _isPressed ? 0.95 : _pulseAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              widget.onPressed();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.emergency.withValues(alpha: 0.9),
                    AppColors.emergency,
                    AppColors.emergency.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergency
                        .withValues(alpha: _glowAnimation.value * 0.5),
                    blurRadius: 40 + (_glowAnimation.value * 20),
                    spreadRadius: 5 + (_glowAnimation.value * 10),
                  ),
                  BoxShadow(
                    color: AppColors.emergency.withValues(alpha: 0.2),
                    blurRadius: 60,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring pulse
                  _buildPulseRing(widget.size + 30, 0.15),
                  _buildPulseRing(widget.size + 60, 0.08),
                  // Icon and text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emergency_outlined,
                        size: widget.size * 0.28,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'HAILMARY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: widget.size * 0.095,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                        ),
                      ),
                      Text(
                        'TAP FOR HELP',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: widget.size * 0.065,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPulseRing(double size, double opacity) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, _) {
        return Container(
          width: size * _pulseAnimation.value,
          height: size * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.emergency
                  .withValues(alpha: opacity * _glowAnimation.value),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
