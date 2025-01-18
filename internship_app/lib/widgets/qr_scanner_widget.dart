import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerWidget extends StatefulWidget {
  final void Function(String) onQrResult;

  const QrScannerWidget({super.key, required this.onQrResult});

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  bool _isFlashOn = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onScanResult(String result) {
    widget.onQrResult(result);
    setState(() {
      _hasScanned = true;
    });
    _controller?.pauseCamera(); // Pause scanning after first result
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR Code Scanned: $result')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scannerWidth = size.width * 0.7;
    final scannerHeight = size.height * 0.7;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height:scannerHeight, 
          width: scannerWidth,
          child: QRView(
            key: qrKey,
            onQRViewCreated: (controller) {
              _controller = controller;
              controller.scannedDataStream.listen((scanData) {
                if (!_hasScanned) {
                  _onScanResult(scanData.code!);
                }
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Align the QR code within the frame to scan.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                if (_controller != null) {
                  await _controller?.toggleFlash();
                  setState(() {
                    _isFlashOn = !_isFlashOn;
                  });
                }
              },
              icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
              label: Text(_isFlashOn ? 'Flash On' : 'Flash Off'),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasScanned = false;
                });
                _controller?.resumeCamera(); // Resume scanning
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('Retry'),
            ),
          ],
        ),
      ],
    );
  }
}
