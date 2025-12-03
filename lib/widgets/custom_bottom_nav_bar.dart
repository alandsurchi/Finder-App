import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: widget.currentIndex.toDouble(),
      end: widget.currentIndex.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(CustomBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _animation = Tween<double>(
        begin: _previousIndex.toDouble(),
        end: widget.currentIndex.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 5;

    return SizedBox(
      height: 100, // Total height including the floating part
      child: Stack(
        children: [
          // Background Painter
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: NavBarPainter(
                    position: _animation.value,
                    itemWidth: itemWidth,
                    color: Colors.white,
                    borderColor: const Color(0xFF2D8CFF),
                  ),
                  size: Size(size.width, 80),
                );
              },
            ),
          ),
          // Icons
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(5, (index) {
                return SizedBox(
                  width: itemWidth,
                  child: _buildNavItem(index, itemWidth),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, double itemWidth) {
    final bool isSelected = widget.currentIndex == index;
    
    // Items data
    final List<Map<String, dynamic>> items = [
      {'icon': Icons.home_outlined, 'activeIcon': Icons.home_filled, 'label': 'Home'},
      {'icon': Icons.search, 'activeIcon': Icons.search, 'label': 'Search'},
      {'icon': Icons.add, 'activeIcon': Icons.add, 'label': 'Post'},
      {'icon': Icons.send_outlined, 'activeIcon': Icons.send, 'label': 'Message'},
      {'icon': Icons.person_outline, 'activeIcon': Icons.person, 'label': 'Profile'},
    ];

    final item = items[index];

    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Floating Circle (Selected State)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: isSelected ? 0 : 35, // Move up when selected
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2D8CFF) : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  isSelected ? item['activeIcon'] : item['icon'],
                  color: isSelected ? const Color(0xFF2D8CFF) : Colors.grey,
                  size: 30,
                ),
              ),
            ),
            // Label
            Positioned(
              bottom: 15,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? Colors.black87 : Colors.grey,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                  fontFamily: 'Poppins', // Assuming Poppins is used
                ),
                child: Text(item['label']),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarPainter extends CustomPainter {
  final double position;
  final double itemWidth;
  final Color color;
  final Color borderColor;

  NavBarPainter({
    required this.position,
    required this.itemWidth,
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    
    // Start point with rounded top-left
    path.moveTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);

    // Calculate the center of the curve based on position
    final double loc = position * itemWidth;
    final double center = loc + (itemWidth / 2);
    
    // Bezier Curve for the notch
    const double notchRadius = 38; // Slightly larger than circle radius (30)
    const double topY = 0;
    const double bottomY = 45; // Depth of the notch
    
    // Line to start of notch
    path.lineTo(center - notchRadius - 10, topY);
    
    // The Notch Curve
    path.cubicTo(
      center - notchRadius, topY,     // Control point 1
      center - notchRadius + 10, bottomY, // Control point 2
      center, bottomY,                // End point (bottom of notch)
    );
    
    path.cubicTo(
      center + notchRadius - 10, bottomY, // Control point 1
      center + notchRadius, topY,     // Control point 2
      center + notchRadius + 10, topY, // End point
    );

    // Line to top-right
    path.lineTo(size.width - 20, topY);
    path.quadraticBezierTo(size.width, topY, size.width, 20);
    
    // Bottom part
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow
    canvas.drawShadow(path, Colors.black.withOpacity(0.1), 5, true);
    
    // Draw background
    canvas.drawPath(path, paint);
    
    // Draw border (only on top)
    final borderPath = Path();
    borderPath.moveTo(0, 20);
    borderPath.quadraticBezierTo(0, 0, 20, 0);
    
    borderPath.lineTo(center - notchRadius - 10, topY);
    borderPath.cubicTo(
      center - notchRadius, topY,
      center - notchRadius + 10, bottomY,
      center, bottomY,
    );
    borderPath.cubicTo(
      center + notchRadius - 10, bottomY,
      center + notchRadius, topY,
      center + notchRadius + 10, topY,
    );
    
    borderPath.lineTo(size.width - 20, topY);
    borderPath.quadraticBezierTo(size.width, topY, size.width, 20);
    
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant NavBarPainter oldDelegate) {
    return oldDelegate.position != position;
  }
}
