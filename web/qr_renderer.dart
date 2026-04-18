import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

class QrRenderer {
  Uint8List generateQrCodeImage(
    String url, {
    required int moduleSize,
    required int padding,
  }) {
    final qrImage = QrImage(
      QrCode.fromData(
        data: url,
        errorCorrectLevel: QrErrorCorrectLevel.L,
      ),
    );

    final moduleCount = qrImage.moduleCount;
    final imageSize = (moduleCount * moduleSize) + (padding * 2);
    final image = img.Image(width: imageSize, height: imageSize);

    img.fill(image, color: img.ColorRgb8(255, 255, 255));

    for (var x = 0; x < moduleCount; x++) {
      for (var y = 0; y < moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          final px = (x * moduleSize) + padding;
          final py = (y * moduleSize) + padding;

          img.fillRect(
            image,
            x1: px,
            y1: py,
            x2: px + moduleSize - 1,
            y2: py + moduleSize - 1,
            color: img.ColorRgb8(0, 0, 0),
          );
        }
      }
    }

    return Uint8List.fromList(img.encodePng(image));
  }
}
