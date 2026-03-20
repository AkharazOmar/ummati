import 'package:flutter/material.dart';

import '../../app/theme.dart';

class IslamicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool showOrnament;

  const IslamicCard({
    super.key,
    required this.child,
    this.padding,
    this.showOrnament = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (showOrnament) ...[
              Positioned(
                top: -8,
                right: -8,
                child: _buildOrnament(),
              ),
              Positioned(
                bottom: -8,
                left: -8,
                child: Transform.rotate(
                  angle: 3.14159,
                  child: _buildOrnament(),
                ),
              ),
            ],
            Padding(
              padding:
                  padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnament() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: UmmatiTheme.accentGold.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: UmmatiTheme.accentGold.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }
}
