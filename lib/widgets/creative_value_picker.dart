import 'package:flutter/material.dart';

/// A horizontal swipeable snapping carousel for choosing one value from a
/// short list — replaces flat chip rows for the "boring" numeric-style
/// onboarding inputs (days/week, session length, assessment levels).
///
/// Browsing (drag) never commits a value on its own — only tapping an
/// option (which also scrolls it to center) calls [onChanged]. That keeps
/// "nothing chosen yet" a real, distinguishable state so screens can still
/// gate their Continue button on [selectedIndex] being null.
class CreativeValuePicker extends StatefulWidget {
  final List<String> options;
  final int? selectedIndex;
  final ValueChanged<int> onChanged;
  final Color accent;
  final Color textColor;
  final Color mutedColor;
  final Color chipBackground;

  const CreativeValuePicker({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    required this.accent,
    required this.textColor,
    required this.mutedColor,
    required this.chipBackground,
  });

  @override
  State<CreativeValuePicker> createState() => _CreativeValuePickerState();
}

class _CreativeValuePickerState extends State<CreativeValuePicker> {
  // Fixed pixel item width + gap — the viewportFraction is derived from the
  // actual available width (see _ensureController) so chips sit a
  // consistent, tight distance apart on any screen size, instead of the
  // wide proportional gaps a fixed 0.3 viewportFraction produces.
  static const double _itemWidth = 68;
  static const double _itemGap = 10;

  PageController? _controller;
  double? _controllerWidth;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _ensureController(double maxWidth) {
    if (_controller != null && _controllerWidth == maxWidth) return;
    _controller?.dispose();
    _controllerWidth = maxWidth;
    final fraction = ((_itemWidth + _itemGap) / maxWidth).clamp(0.05, 1.0);
    _controller = PageController(
      viewportFraction: fraction,
      initialPage: widget.selectedIndex ?? 0,
    );
  }

  void _select(int index) {
    widget.onChanged(index);
    _controller?.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: LayoutBuilder(
        builder: (context, constraints) {
          _ensureController(constraints.maxWidth);
          final controller = _controller!;
          return PageView.builder(
            controller: controller,
            padEnds: true,
            itemCount: widget.options.length,
            itemBuilder: (context, index) {
              final selected = widget.selectedIndex == index;
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  double page;
                  if (controller.hasClients &&
                      controller.position.haveDimensions) {
                    page = controller.page ?? controller.initialPage.toDouble();
                  } else {
                    page = controller.initialPage.toDouble();
                  }
                  final distance = (page - index).abs().clamp(0.0, 1.5);
                  final scale = (1.0 - distance * 0.28).clamp(0.6, 1.0);
                  final opacity = (1.0 - distance * 0.55).clamp(0.35, 1.0);
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: Center(
                  child: GestureDetector(
                    onTap: () => _select(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      width: _itemWidth,
                      height: _itemWidth,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: widget.chipBackground,
                        border: Border.all(
                          color: selected ? widget.accent : Colors.transparent,
                          width: 1.5,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: widget.accent.withValues(alpha: 0.25),
                                  blurRadius: 16,
                                  spreadRadius: 1,
                                ),
                              ]
                            : const [],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.options[index],
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: selected ? widget.accent : widget.textColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
