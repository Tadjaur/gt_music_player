import 'package:flutter/material.dart';

class Neumorphic extends StatefulWidget {
  final Widget child;
  final double bevel;

  final Offset blurOffset;
  final Color color;

  Neumorphic({Key key, this.child, this.bevel = 25, this.color})
      : this.blurOffset = Offset(bevel / 2, bevel / 2),
        super(key: key);

  @override
  _NeumorphicState createState() => _NeumorphicState();
}

class _NeumorphicState extends State<Neumorphic> {
  bool _isPressed = false;

  void _onPointerCancel(PointerCancelEvent event) {
    setState(() {
      _isPressed = false;
    });
  }

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = this.widget.color ?? Theme.of(context).backgroundColor;
    final colors = [
      color.mix(Colors.white, .3),
      color.mix(Colors.black, .2),
    ];
    final colors2 = [
      color.mix(Colors.white, .3),
      color.mix(Colors.black, .2),
    ];
    final shadows1 = [
      BoxShadow(blurRadius: widget.bevel, offset: -widget.blurOffset, color: color.mix(Colors.white, .7)),
      BoxShadow(blurRadius: widget.bevel, offset: widget.blurOffset, color: color.mix(Colors.black, 0.3))
    ];
    final shadows = [
      BoxShadow(blurRadius: widget.bevel * 1.1, offset: -widget.blurOffset * 1.2, color: color.mix(Colors.white, .7)),
      BoxShadow(blurRadius: widget.bevel * 1.1, offset: widget.blurOffset * 1.2, color: color.mix(Colors.black, 0.3))
    ];
    final shadows2 = [
      BoxShadow(blurRadius: widget.bevel / 5, offset: widget.blurOffset / 5, color: color.mix(Colors.white, .7)),
      BoxShadow(blurRadius: widget.bevel / 5, offset: -widget.blurOffset / 5, color: color.mix(Colors.black, 0.3))
    ];
//    return buildListener(shadows, colors);
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 225),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(200),
          boxShadow: _isPressed ? shadows : shadows1,
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 225),
          decoration: BoxDecoration(
              boxShadow: !_isPressed ? null : shadows2,
              borderRadius: BorderRadius.circular(200),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors.reversed.toList(),
              )),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 225),
            padding: EdgeInsets.all(!_isPressed ? 35 : 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: !_isPressed ? colors : colors,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Listener buildListener(List<BoxShadow> shadows, List<Color> colors) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: AnimatedContainer(
          duration: Duration(milliseconds: 1000),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(200),
            color: Color.lerp(Colors.grey.shade200, Colors.blueGrey.shade200, .5),
            border: !_isPressed
                ? null
                : Border(
                    bottom: BorderSide(color: Colors.white24, width: 5, style: BorderStyle.solid),
                    right: BorderSide(color: Colors.white24, width: 5, style: BorderStyle.solid),
                    top: BorderSide(color: Colors.black26, width: 5, style: BorderStyle.solid),
                    left: BorderSide(color: Colors.black26, width: 5, style: BorderStyle.solid),
                  ),
            boxShadow: _isPressed ? null : shadows,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: !_isPressed ? colors : colors.reversed.toList(),
            ),
          ),
          padding: EdgeInsets.all(35),
          child: Transform.scale(scale: !_isPressed ? 1 : 0.3, child: widget.child)),
    );
  }
}

extension Cl on Color {
  Color mix(Color a, [double amount]) {
    if (amount == null || amount <= 0) amount = 0.5;
    amount.clamp(0, 1);
    return Color.lerp(this, a, amount);
  }
}
