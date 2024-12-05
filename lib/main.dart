import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:torch_light/torch_light.dart';

void main() {
  runApp(DragGestureApp());
}

class DragGestureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag Gesture App',
      home: DragGestureScreen(),
    );
  }
}

class DragGestureScreen extends StatefulWidget {
  @override
  _DragGestureScreenState createState() => _DragGestureScreenState();
}

class _DragGestureScreenState extends State<DragGestureScreen> {
  Color _backgroundColor = Colors.blue;
  String _gestureDescription = 'Use one finger to drag';
  Offset _startOffset = Offset.zero;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen(_onAccelerometerEvent);
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Simple shake detection logic
    const double shakeThreshold = 15.0;
    if (event.x.abs() > shakeThreshold ||
        event.y.abs() > shakeThreshold ||
        event.z.abs() > shakeThreshold) {
      _toggleFlashlight();
    }
  }

  void _toggleFlashlight() async {
    if (_isFlashOn) {
      await TorchLight.disableTorch();
      setState(() {
        _isFlashOn = false;
      });
    } else {
      try {
        await TorchLight.enableTorch();
        setState(() {
          _isFlashOn = true;
        });
      } on Exception catch (e) {
        print('Could not enable flashlight: $e');
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    // Capture the initial position when the gesture starts
    _startOffset = details.focalPoint;
    _updateGestureDetails(details.pointerCount, Offset.zero);
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    // Calculate the delta from the initial position to determine the drag direction
    Offset delta = details.focalPoint - _startOffset;
    _updateGestureDetails(details.pointerCount, delta);
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    setState(() {
      _backgroundColor = Colors.blue;
      _gestureDescription = 'Use one finger to drag';
    });
  }

  void _updateGestureDetails(int pointerCount, Offset delta) {
    String direction = '';
    Color color;

    if (delta.dx.abs() > delta.dy.abs()) {
      // Horizontal movement
      if (delta.dx > 0) {
        direction = 'Horizontal Right';
        color = Colors.red;
      } else {
        direction = 'Horizontal Left';
        color = Colors.orange;
      }
    } else {
      // Vertical movement
      if (delta.dy > 0) {
        direction = 'Vertical Down';
        color = Colors.green;
      } else {
        direction = 'Vertical Up';
        color = Colors.purple;
      }
    }

    setState(() {
      _backgroundColor = color;
      if (pointerCount > 1) {
        _gestureDescription =
            'Dragging with more than one finger\nDirection: $direction';
      } else {
        _gestureDescription = 'Dragging with one finger\nDirection: $direction';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      onScaleEnd: _handleScaleEnd,
      child: Container(
        color: _backgroundColor,
        child: Center(
          child: Text(
            _gestureDescription,
            style: TextStyle(fontSize: 24, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
