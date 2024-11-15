import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../providers/warehouse_provider.dart';
import '../models/stock_item.dart';
import '../widgets/stock_update_dialog.dart'; // Import StockUpdateDialog

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> with WidgetsBindingObserver {
  MobileScannerController? cameraController;
  bool isStarted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  void _initializeCamera() {
    if (cameraController == null) {
      setState(() {
        cameraController = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.back,
          torchEnabled: false,
        );
      });
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _initializeCamera();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        cameraController?.dispose();
        cameraController = null;
        break;
      default:
        break;
    }
  }

  Future<void> _handleDetection(BarcodeCapture capture) async {
    if (!mounted) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final Barcode barcode = barcodes.first;
    final String? rawValue = barcode.rawValue;
    if (rawValue == null) return;

    try {
      // Get StockProvider before async operation
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final item = stockProvider.findByBarcode(rawValue);
      
      if (!mounted) return;
      
      if (item == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => StockUpdateDialog(item: item),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController?.torchState ?? ValueNotifier(TorchState.off),
              builder: (context, state, child) {
                if (state == TorchState.off) {
                  return const Icon(Icons.flash_off, color: Colors.grey);
                } else {
                  return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController?.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController?.cameraFacingState ?? ValueNotifier(CameraFacing.back),
              builder: (context, state, child) {
                if (state == CameraFacing.front) {
                  return const Icon(Icons.camera_front);
                } else {
                  return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController?.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _handleDetection,
          ),
          const CustomPaint(
            painter: ScannerOverlay(),
            size: Size.infinite,
            child: SizedBox.expand(),
          ),
          const Align(
            alignment: Alignment.center,
            child: ScanningLine(),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay();

  static const double _borderWidth = 10;
  static const double _cornerRadius = 10;
  static const Color _borderColor = Colors.blue;

  @override
  void paint(Canvas canvas, Size size) {
    const double scanAreaWidth = 200;
    const double scanAreaHeight = 200;

    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(size.width / 2, size.height / 2),
                width: scanAreaWidth,
                height: scanAreaHeight,
              ),
              const Radius.circular(_cornerRadius),
            ),
          ),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = _borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: scanAreaWidth,
          height: scanAreaHeight,
        ),
        const Radius.circular(_cornerRadius),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanningLine extends StatelessWidget {
  const ScanningLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      width: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.transparent, Colors.blue, Colors.transparent],
        ),
      ),
    );
  }
}