import 'package:flutter/material.dart';
import '../models/uno_card.dart';

class PlayerCard extends StatefulWidget {
  final UnoCard card;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const PlayerCard({
    required this.card,
    this.onTap,
    this.width = 60,
    this.height = 90,
    Key? key,
  }) : super(key: key);

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getCardColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.black;
    }
  }

  String _getDisplayText() {
    switch (widget.card.value.toLowerCase()) {
      case 'reverse':
        return '⟲'; // Unicode reverse arrow
      case 'skip':
        return '⊘'; // Unicode no symbol
      case 'draw two':
        return '+2';
      case 'wild':
        return '★'; // Unicode star
      case 'wild draw four':
        return '+4';
      default:
        return widget.card.value;
    }
  }

  TextStyle _getTextStyle() {
    // Adjust size based on text length
    final isSpecialCard = widget.card.isActionCard || widget.card.isWild;
    final baseSize = isSpecialCard ? 20.0 : 24.0;

    return TextStyle(
      color: Colors.white,
      fontSize: baseSize,
      fontWeight: FontWeight.bold,
      shadows: const [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black26,
          offset: Offset(1.0, 1.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
          _controller.reverse();
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: isHovered ? 12 : 8,
                  offset: isHovered ? const Offset(0, 6) : const Offset(0, 4),
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getCardColor(widget.card.color),
                  _getCardColor(widget.card.color).withOpacity(0.8),
                ],
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getDisplayText(),
                  style: _getTextStyle(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
