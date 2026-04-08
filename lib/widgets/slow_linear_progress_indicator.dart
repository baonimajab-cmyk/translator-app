import 'package:flutter/material.dart';

/// 横向不确定进度条，动画周期可配置（[period] 越长，视觉上越慢）。
/// 用于替代 [LinearProgressIndicator] 在 indeterminate 模式下无法调节速度的问题。
class SlowLinearProgressIndicator extends StatefulWidget {
  const SlowLinearProgressIndicator({
    super.key,
    this.color = const Color.fromARGB(255, 255, 0, 0),
    this.backgroundColor = Colors.transparent,
    this.minHeight = 2,
    this.period = const Duration(milliseconds: 3200),
    this.segmentFraction = 0.38,
  });

  final Color color;
  final Color backgroundColor;
  final double minHeight;

  /// 完整来回一遍的时长，越大越慢。
  final Duration period;

  /// 滑块宽度占可用宽度的比例 (0~1)。
  final double segmentFraction;

  @override
  State<SlowLinearProgressIndicator> createState() =>
      _SlowLinearProgressIndicatorState();
}

class _SlowLinearProgressIndicatorState extends State<SlowLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void didUpdateWidget(SlowLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
      if (_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w <= 0) {
          return SizedBox(height: widget.minHeight);
        }
        final segW = (w * widget.segmentFraction).clamp(8.0, w);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // 0 -> 滑块从左侧外进入；1 -> 移出右侧，视觉上与常见 indeterminate 条类似。
            final t = _controller.value;
            final dx = -segW + t * (w + segW);

            return ClipRect(
              child: ColoredBox(
                color: widget.backgroundColor,
                child: SizedBox(
                  height: widget.minHeight,
                  width: w,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Transform.translate(
                        offset: Offset(dx, 0),
                        child: Container(
                          width: segW,
                          height: widget.minHeight,
                          color: widget.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
