import 'package:flutter/material.dart';

/// Hover effect wrapper for any widget - adds scale and color effects on hover
class HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;
  final Color? hoverColor;
  final Duration duration;
  final BorderRadius? borderRadius;

  const HoverButton({
    super.key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.02,
    this.hoverColor,
    this.duration = const Duration(milliseconds: 150),
    this.borderRadius,
  });

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: widget.duration,
          transform: Matrix4.identity()..scale(_isHovered ? widget.hoverScale : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor : null,
            borderRadius: widget.borderRadius,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Icon button with hover effect
class HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final Color? hoverColor;
  final Color? backgroundColor;
  final Color? hoverBackgroundColor;

  const HoverIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 24,
    this.color,
    this.hoverColor,
    this.backgroundColor,
    this.hoverBackgroundColor,
  });

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered 
                ? (widget.hoverBackgroundColor ?? Colors.grey.shade100) 
                : widget.backgroundColor,
            shape: BoxShape.circle,
          ),
          child: AnimatedScale(
            scale: _isHovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: _isHovered ? (widget.hoverColor ?? widget.color) : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

/// Add to cart button with hover effect
class AddToCartButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isAdded;

  const AddToCartButton({
    super.key,
    this.onTap,
    this.isAdded = false,
  });

  @override
  State<AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<AddToCartButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFD70F64) : Colors.white,
            border: Border.all(
              color: _isHovered ? const Color(0xFFD70F64) : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: const Color(0xFFD70F64).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: AnimatedScale(
            scale: _isHovered ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Icon(
              Icons.add,
              size: 20,
              color: _isHovered ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/// Primary action button with hover effect (Foodpanda pink)
class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final bool enabled;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.enabled = true,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.enabled ? const Color(0xFFD70F64) : Colors.grey.shade300;
    final hoverColor = widget.enabled ? const Color(0xFFB40D55) : Colors.grey.shade300;
    
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => widget.enabled ? setState(() => _isHovered = true) : null,
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => widget.enabled ? setState(() => _isPressed = true) : null,
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: _isPressed ? hoverColor.withOpacity(0.8) : (_isHovered ? hoverColor : baseColor),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovered && widget.enabled ? [
              BoxShadow(
                color: baseColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ] : null,
          ),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  color: widget.enabled ? Colors.white : Colors.grey.shade500,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category tab with hover effect
class CategoryTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryTab({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isSelected 
                    ? const Color(0xFFD70F64) 
                    : (_isHovered ? Colors.grey.shade400 : Colors.transparent),
                width: 2,
              ),
            ),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                color: widget.isSelected 
                    ? const Color(0xFFD70F64) 
                    : (_isHovered ? Colors.black : Colors.grey.shade600),
                fontWeight: widget.isSelected || _isHovered ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}

/// Quantity button with hover effect
class QuantityButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const QuantityButton({
    super.key,
    required this.icon,
    this.onTap,
  });

  @override
  State<QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<QuantityButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFD70F64).withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedScale(
            scale: _isHovered ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Icon(
              widget.icon, 
              size: 16,
              color: _isHovered ? const Color(0xFFD70F64) : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

/// Toggle button (Delivery/Pickup) with hover effect
class ToggleButton extends StatefulWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isLeft;
  final bool isRight;

  const ToggleButton({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onTap,
    this.isLeft = false,
    this.isRight = false,
  });

  @override
  State<ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered && !widget.isSelected ? Colors.grey.shade50 : Colors.white,
            border: Border.all(
              color: widget.isSelected ? Colors.black : Colors.grey.shade300,
              width: widget.isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.horizontal(
              left: widget.isLeft ? const Radius.circular(8) : Radius.zero,
              right: widget.isRight ? const Radius.circular(8) : Radius.zero,
            ),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontWeight: widget.isSelected || _isHovered ? FontWeight.w600 : FontWeight.normal,
                color: widget.isSelected ? Colors.black : (_isHovered ? Colors.black87 : Colors.grey.shade600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
