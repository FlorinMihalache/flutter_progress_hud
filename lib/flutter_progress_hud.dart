library flutter_progress_hud;

import 'package:flutter/material.dart';

class ProgressHUD extends StatefulWidget {
  final Widget child;
  final Color indicatorColor;
  final Widget? indicatorWidget;
  final Color backgroundColor;
  final Radius backgroundRadius;
  final Color borderColor;
  final double borderWidth;
  final bool barrierEnabled;
  final Color barrierColor;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;

  ProgressHUD(
      {required this.child,
      this.indicatorColor = Colors.white,
      this.indicatorWidget,
      this.backgroundColor = Colors.black54,
      this.backgroundRadius = const Radius.circular(8.0),
      this.borderColor = Colors.white,
      this.borderWidth = 0.0,
      this.barrierEnabled = true,
      this.barrierColor = Colors.black12,
      this.textStyle = const TextStyle(color: Colors.white, fontSize: 14.0),
      this.padding = const EdgeInsets.all(16.0)});

  static _ProgressHUDState? of(BuildContext context) {
    final progressHudState = context.findAncestorStateOfType<_ProgressHUDState>();

    assert(() {
      if (progressHudState == null) {
        throw FlutterError(
            'ProgressHUD operation requested with a context that does not include a ProgressHUD.\n'
            'The context used to show ProgressHUD must be that of a widget '
            'that is a descendant of a ProgressHUD widget.');
      }
      return true;
    }());

    return progressHudState;
  }

  @override
  _ProgressHUDState createState() => _ProgressHUDState();
}

class _ProgressHUDState extends State<ProgressHUD>
    with SingleTickerProviderStateMixin {
  bool _isShow = false;
  bool _barrierVisible = false;
  String? _text;

  late AnimationController _controller;
  late Animation _animation;

  void show() {
    if (mounted) {
      setState(() {
        _text = null;
        _controller.forward();
        _isShow = true;
      });
    }
  }

  void showWithText(String text) {
   if (mounted) {
      setState(() {
        _text = text;
        _controller.forward();
        _isShow = true;
      });
    }
  }

  void dismiss() {
    if (mounted) {
      setState(() {
        _controller.reverse();
        _isShow = false;
      });
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _animation.addStatusListener((status) {
      setState(() {
        _barrierVisible = status != AnimationStatus.dismissed;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (widget.barrierEnabled) {
      children.add(
        Visibility(
          visible: _barrierVisible,
          child: ModalBarrier(
            color: widget.barrierColor,
            dismissible: false,
          ),
        ),
      );
    }
    children.add(Center(child: _buildProgress()));

    return Stack(
      children: <Widget>[
        widget.child,
        IgnorePointer(
          ignoring: !_isShow,
          child: TickerMode(
            enabled: _isShow,
            child: FadeTransition(
              opacity: _animation as Animation<double>,
              child: Stack(children: children),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    final contentChildren = <Widget>[
      widget.indicatorWidget ?? _buildDefaultIndicator()
    ];

    if (_text != null && _text!.isNotEmpty) {
      contentChildren.addAll(<Widget>[
        SizedBox(height: 16.0),
        Text(
          _text!,
          style: widget.textStyle,
        ),
      ]);
    }

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.all(widget.backgroundRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          )),
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: contentChildren,
        ),
      ),
    );
  }

  Widget _buildDefaultIndicator() {
    return Container(
      width: 40.0,
      height: 40.0,
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation(widget.indicatorColor),
      ),
    );
  }
}
