import 'dart:async';

import 'core/constants/app_config.dart';
import 'id_generator.dart';
import 'qr_renderer.dart';
import 'services/id_availability_service.dart';
import 'services/local_id_store.dart';
import 'zip_service.dart';

class GenerationRequest {
  final String baseUrl;
  final int numberOfCodes;
  final int moduleSize;
  final int padding;

  const GenerationRequest({
    required this.baseUrl,
    required this.numberOfCodes,
    required this.moduleSize,
    required this.padding,
  });
}

class GenerationResult {
  final int existingIds;
  final int newIdsGenerated;
  final int totalIds;
  final Duration elapsed;
  final String zipFileName;

  const GenerationResult({
    required this.existingIds,
    required this.newIdsGenerated,
    required this.totalIds,
    required this.elapsed,
    required this.zipFileName,
  });
}

class GenerationController {
  final IdGenerator _idGenerator;
  final QrRenderer _qrRenderer;
  final LocalIdStore _localIdStore;

  GenerationController({
    IdGenerator? idGenerator,
    QrRenderer? qrRenderer,
    LocalIdStore? localIdStore,
  })
    : _idGenerator = idGenerator ?? IdGenerator(),
      _qrRenderer = qrRenderer ?? QrRenderer(),
      _localIdStore = localIdStore ?? LocalIdStore();

  Future<GenerationResult> generate({
    required GenerationRequest request,
    void Function(String status)? onStatus,
    void Function(int generated, int total)? onProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    final zipService = ZipService();

    onStatus?.call('Loading existing IDs...');
    final existingIds = await _localIdStore.loadExistingIds();
    final allIds = List<String>.from(existingIds);
    final idSet = existingIds.toSet();
    final idAvailabilityService = IdAvailabilityService(idSet);

    onStatus?.call(
      'Found ${existingIds.length} existing IDs. Generating ${request.numberOfCodes} new IDs...',
    );

    for (var i = 1; i <= request.numberOfCodes; i++) {
      final uniqueId = await _idGenerator.generateUniqueId(
        idAvailabilityService.isIdAvailable,
      );
      idAvailabilityService.markIdAsUsed(uniqueId);
      allIds.add(uniqueId);

      final url = '${request.baseUrl}$uniqueId';
      final pngBytes = _qrRenderer.generateQrCodeImage(
        url,
        moduleSize: request.moduleSize,
        padding: request.padding,
      );

      zipService.addQrCodeImage(uniqueId, pngBytes);

      if (i % 250 == 0 || i == request.numberOfCodes) {
        onProgress?.call(i, request.numberOfCodes);
        await Future<void>.delayed(Duration.zero);
      }
    }

    zipService.addIdsFile(AppConfig.idsFilePath, allIds);
    onStatus?.call('Creating ZIP archive...');
    final zipFileName = zipService.downloadZip();

    return GenerationResult(
      existingIds: existingIds.length,
      newIdsGenerated: request.numberOfCodes,
      totalIds: allIds.length,
      elapsed: stopwatch.elapsed,
      zipFileName: zipFileName,
    );
  }
}
