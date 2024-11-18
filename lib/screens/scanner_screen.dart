import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/stock_provider.dart';
import '../widgets/stock_update_dialog.dart';
import '../utils/route_observer.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with RouteAware {
  bool isProcessing = false;
  bool hasError = false;
  String errorMessage = '';
  MobileScannerController? controller;
  bool _isInitialized = false;
  bool _isFromAddStock = false;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    // Check if we came from add_stock_dialog
    _isFromAddStock = ModalRoute.of(context)?.settings.arguments as bool? ?? false;
  }

  @override
  void didPushNext() {
    // Called when leaving this screen
    _disposeScanner();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen
    _initializeScanner();
  }

  void _initializeScanner() {
    if (!_isInitialized) {
      controller = MobileScannerController(
        facing: CameraFacing.back,
        formats: const [BarcodeFormat.qrCode, BarcodeFormat.ean13],
      );
      _isInitialized = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _disposeScanner() {
    if (_isInitialized && controller != null) {
      controller!.dispose();
      controller = null;
      _isInitialized = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _disposeScanner();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing || !mounted) return;
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    setState(() {
      isProcessing = true;
    });

    final barcode = barcodes.first.rawValue!;
    
    // Pause scanner while processing
    controller?.stop();
    
    if (!mounted) return;

    if (_isFromAddStock) {
      // If coming from add_stock_dialog, just return the barcode
      Navigator.pop(context, barcode);
    } else {
      // If from main menu, show stock update dialog
      final stockProvider = Provider.of<StockProvider>(context, listen: false);
      final item = await stockProvider.findItemByBarcode(barcode);
      
      if (!mounted) return;

      if (item != null) {
        // Show stock update dialog only if we're still on this screen
        if (mounted && _isInitialized) {
          await showDialog(
            context: context,
            builder: (context) => StockUpdateDialog(item: item),
          ).then((_) {
            // Restart scanner after dialog is closed if we're still on this screen
            if (mounted && _isInitialized) {
              controller?.start();
            }
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item not found'),
            backgroundColor: Colors.red,
          ),
        );
        // Restart scanner if we're still on this screen
        if (mounted && _isInitialized) {
          controller?.start();
        }
      }
    }

    if (mounted) {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          _disposeScanner();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: controller?.torchState ?? ValueNotifier(TorchState.off),
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off);
                    case TorchState.on:
                      return const Icon(Icons.flash_on);
                  }
                },
              ),
              onPressed: () => controller?.toggleTorch(),
            ),
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: controller?.cameraFacingState ?? ValueNotifier(CameraFacing.back),
                builder: (context, state, child) {
                  switch (state) {
                    case CameraFacing.front:
                      return const Icon(Icons.camera_front);
                    case CameraFacing.back:
                      return const Icon(Icons.camera_rear);
                  }
                },
              ),
              onPressed: () => controller?.switchCamera(),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                hasError = false;
                                errorMessage = '';
                              });
                              _initializeScanner();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        if (controller != null && _isInitialized) MobileScanner(
                          controller: controller!,
                          onDetect: _onDetect,
                          errorBuilder: (context, error, child) {
                            return Center(
                              child: Text(
                                'Error: ${error.errorDetails?.message ?? "Unknown error"}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                        Center(
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  isProcessing ? 'Processing...' : 'Scan a QR code',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
