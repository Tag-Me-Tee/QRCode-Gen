import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';

class ZipService {
  final Archive _archive = Archive();

  void addQrCodeImage(String uniqueId, Uint8List pngBytes) {
    _archive.addFile(
      ArchiveFile('qr_codes/qr_$uniqueId.png', pngBytes.length, pngBytes),
    );
  }

  void addIdsFile(String idsFilePath, List<String> allIds) {
    final idsContent = allIds.join('\n');
    _archive.addFile(
      ArchiveFile(idsFilePath, idsContent.length, idsContent.codeUnits),
    );
  }

  String downloadZip() {
    final zipBytes = ZipEncoder().encode(_archive);
    final fileName = 'qr_codes_${DateTime.now().millisecondsSinceEpoch}.zip';

    _downloadFile(
      Uint8List.fromList(zipBytes),
      fileName,
      'application/zip',
    );

    return fileName;
  }

  void _downloadFile(Uint8List bytes, String fileName, String mimeType) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);

    html.Url.revokeObjectUrl(url);
  }
}
