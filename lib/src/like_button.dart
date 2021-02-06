///
///  create by zmtzawqlp on 2019/5/27
///
import 'package:flutter/material.dart';
import 'package:like_button/src/painter/bubbles_painter.dart';
import 'package:like_button/src/painter/circle_painter.dart';
import 'package:like_button/src/utils/like_button_model.dart';
import 'package:like_button/src/utils/like_button_typedef.dart';
import 'package:like_button/src/utils/like_button_util.dart';

class BeLikeButton extends StatefulWidget {
  ///size of like widget
  final double size;

  ///animation duration to change isLiked state
  final Duration animationDuration;

  ///total size of bubbles
  final double bubblesSize;

  ///colors of bubbles
  final BubblesColor bubblesColor;

  ///size of circle
  final double circleSize;

  ///colors of circle
  final CircleColor circleColor;

  /// tap call back of like button
  final LikeButtonTapCallback onTap;

  ///whether it is liked
  final bool isLiked;

  ///like count
  ///if null, will not show
  final int likeCount;

  /// mainAxisAlignment for like button
  final MainAxisAlignment mainAxisAlignment;

  // crossAxisAlignment for like button
  final CrossAxisAlignment crossAxisAlignment;

  ///builder to create like widget
  final LikeWidgetBuilder likeBuilder;

  ///builder to create like count widget
  final LikeCountWidgetBuilder countBuilder;

  ///animation duration to change like count
  final Duration likeCountAnimationDuration;

  ///animation type to change like count(none,part,all)
  final LikeCountAnimationType likeCountAnimationType;

  ///padding for like count widget
  final EdgeInsetsGeometry likeCountPadding;

  ///like count widget postion
  ///left of like widget
  ///right of like widget
  ///top of like widget
  ///bottom of like widget
  final CountPostion countPostion;

  /// padding of like button
  final EdgeInsetsGeometry padding;

  ///return count widget with decoration
  final CountDecoration countDecoration;

  final bool Function() preTapValidation;
  final VoidCallback onTapInvalid;

  const BeLikeButton(
      {Key key,
      this.size: 30.0,
      this.likeBuilder,
      this.countBuilder,
      double bubblesSize,
      double circleSize,
      this.likeCount,
      this.isLiked: false,
      this.preTapValidation,
      this.onTapInvalid,
      this.mainAxisAlignment: MainAxisAlignment.center,
      this.crossAxisAlignment: CrossAxisAlignment.center,
      this.animationDuration = const Duration(milliseconds: 1000),
      this.likeCountAnimationType = LikeCountAnimationType.part,
      this.likeCountAnimationDuration = const Duration(milliseconds: 500),
      this.likeCountPadding = const EdgeInsets.only(left: 3.0),
      this.bubblesColor = const BubblesColor(
        dotPrimaryColor: const Color(0xFFFFC107),
        dotSecondaryColor: const Color(0xFFFF9800),
        dotThirdColor: const Color(0xFFFF5722),
        dotLastColor: const Color(0xFFF44336),
      ),
      this.circleColor = const CircleColor(start: const Color(0xFFFF5722), end: const Color(0xFFFFC107)),
      this.onTap,
      this.countPostion: CountPostion.right,
      this.padding,
      this.countDecoration})
      : assert(size != null),
        assert(animationDuration != null),
        assert(circleColor != null),
        assert(bubblesColor != null),
        //assert(isLiked != null),
        assert(mainAxisAlignment != null),
        assert(crossAxisAlignment != null),
        bubblesSize = bubblesSize ?? size * 2.0,
        circleSize = circleSize ?? size * 0.8,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _BeLikeButtonState();
}

class _BeLikeButtonState extends State<BeLikeButton> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _outerCircleAnimation;
  Animation<double> _innerCircleAnimation;
  Animation<double> _scaleAnimation;
  Animation<double> _bubblesAnimation;
  Animation<Offset> _slidePreValueAnimation;
  Animation<Offset> _slideCurrentValueAnimation;
  Animation<double> _opacityAnimation;

  bool _isLiked = false;
  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;

    _controller = AnimationController(duration: widget.animationDuration, vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onTap != null) {
          widget.onTap((_isLiked ?? true));
        }
      }
    });

    _initAnimations();
  }

  @override
  void didUpdateWidget(BeLikeButton oldWidget) {
    _isLiked = widget.isLiked;

    _controller = AnimationController(duration: widget.animationDuration, vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.onTap != null) {
          widget.onTap((_isLiked ?? true));
        }
      }
    });

    _initAnimations();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      AnimatedBuilder(
        animation: _controller,
        builder: (c, w) {
          var likeWidget =
              widget.likeBuilder?.call((_isLiked ?? true)) ?? defaultWidgetBuilder((_isLiked ?? true), widget.size);
          return Stack(
            overflow: Overflow.visible,
            children: <Widget>[
              Positioned(
                top: (widget.size - widget.bubblesSize) / 2.0,
                left: (widget.size - widget.bubblesSize) / 2.0,
                child: CustomPaint(
                  size: Size(widget.bubblesSize, widget.bubblesSize),
                  painter: BubblesPainter(
                    currentProgress: _bubblesAnimation.value,
                    color1: widget.bubblesColor.dotPrimaryColor,
                    color2: widget.bubblesColor.dotSecondaryColor,
                    color3: widget.bubblesColor.dotThirdColorReal,
                    color4: widget.bubblesColor.dotLastColorReal,
                  ),
                ),
              ),
              Positioned(
                top: (widget.size - widget.circleSize) / 2.0,
                left: (widget.size - widget.circleSize) / 2.0,
                child: CustomPaint(
                  size: Size(widget.circleSize, widget.circleSize),
                  painter: CirclePainter(
                    innerCircleRadiusProgress: _innerCircleAnimation.value,
                    outerCircleRadiusProgress: _outerCircleAnimation.value,
                    circleColor: widget.circleColor,
                  ),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                alignment: Alignment.center,
                child: Transform.scale(
                  scale: ((_isLiked ?? true) && _controller.isAnimating) ? _scaleAnimation.value : 1.0,
                  child: SizedBox(
                    child: likeWidget,
                    height: widget.size,
                    width: widget.size,
                  ),
                ),
              ),
            ],
          );
        },
      )
    ];

    Widget result = Row(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: children,
    );

    if (widget.padding != null) {
      result = Padding(
        padding: widget.padding,
        child: result,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onTap,
      child: result,
    );
  }

  void _onTap() {
    if (_controller.isAnimating) return;
    if (widget.preTapValidation() == false) {
      widget.onTapInvalid();
      return;
    }

    _handleIsLikeChanged(!(_isLiked ?? true));
  }

  void _handleIsLikeChanged(bool isLiked) {
    if (_isLiked == null) {
      if (mounted) {
        setState(() {
          _controller.reset();
          _controller.forward();
        });
      }
      return;
    }

    if (isLiked != null && isLiked != _isLiked) {
      _isLiked = isLiked;

      if (mounted) {
        setState(() {
          if (_isLiked) {
            _controller.reset();
            _controller.forward();
          } else {
            if (widget.onTap != null) {
              widget.onTap((_isLiked ?? true));
            }
          }
        });
      }
    }
  }

  void _initAnimations() {
    _initControlAnimation();
  }

  void _initControlAnimation() {
    _outerCircleAnimation = new Tween<double>(
      begin: 0.1,
      end: 1.0,
    ).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: new Interval(
          0.0,
          0.3,
          curve: Curves.ease,
        ),
      ),
    );
    _innerCircleAnimation = new Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: new Interval(
          0.2,
          0.5,
          curve: Curves.ease,
        ),
      ),
    );
    _scaleAnimation = new Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: new Interval(
          0.35,
          0.7,
          curve: OvershootCurve(),
        ),
      ),
    );
    _bubblesAnimation = new Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: new Interval(
          0.1,
          1.0,
          curve: Curves.decelerate,
        ),
      ),
    );
  }
}
