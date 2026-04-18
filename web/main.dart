import 'dart:html' as html;
import 'generation_controller.dart';

Future<void> main() async {
  final form = _AppForm.fromDom();
  final controller = GenerationController();

  form.setDefaults(
    numberOfCodes: 5000,
    moduleSize: 10,
    padding: 20,
    baseUrl: 'https://mohamed-7018.github.io/tag-me-tee/?id=',
  );

  form.onGenerateClicked(() async {
    form.clearMessages();

    final request = form.readRequest();
    if (request == null) {
      return;
    }

    form.setBusy(true);
    form.setStatus('Starting generation...');
    form.setProgress('0/${request.numberOfCodes} generated');

    try {
      final result = await controller.generate(
        request: request,
        onStatus: form.setStatus,
        onProgress: (generated, total) {
          form.setProgress('$generated/$total generated');
        },
      );

      form.setProgress('${result.newIdsGenerated}/${result.newIdsGenerated} generated');
      form.setSuccess(
        'Generation complete. Existing IDs: ${result.existingIds}, '
        'New IDs: ${result.newIdsGenerated}, Total IDs: ${result.totalIds}, '
        'Time: ${(result.elapsed.inMilliseconds / 1000).toStringAsFixed(1)}s. '
        'Downloaded: ${result.zipFileName}.',
      );
      form.setStatus(
        'Important: Replace the served gen_ids.txt with the updated one from the downloaded ZIP before your next run.',
      );
    } catch (e) {
      form.setError('Generation failed: $e');
      form.setStatus('Generation failed.');
    } finally {
      form.setBusy(false);
    }
  });

  form.onResetClicked(() {
    form.setDefaults(
      numberOfCodes: 5000,
      moduleSize: 10,
      padding: 20,
      baseUrl: 'https://mohamed-7018.github.io/tag-me-tee/?id=',
    );
    form.clearMessages();
    form.setStatus('Ready. Configure values and click Generate QR Codes.');
  });

  form.setStatus('Ready. Configure values and click Generate QR Codes.');
}

class _AppForm {
  final html.InputElement numberOfCodesInput;
  final html.InputElement moduleSizeInput;
  final html.InputElement paddingInput;
  final html.InputElement baseUrlInput;
  final html.ButtonElement generateButton;
  final html.ButtonElement resetButton;
  final html.DivElement statusElement;
  final html.DivElement progressElement;
  final html.DivElement messageElement;

  _AppForm({
    required this.numberOfCodesInput,
    required this.moduleSizeInput,
    required this.paddingInput,
    required this.baseUrlInput,
    required this.generateButton,
    required this.resetButton,
    required this.statusElement,
    required this.progressElement,
    required this.messageElement,
  });

  factory _AppForm.fromDom() {
    T requireElement<T extends html.Element>(String id) {
      final element = html.document.getElementById(id);
      if (element is! T) {
        throw StateError('Missing required element: $id');
      }
      return element;
    }

    return _AppForm(
      numberOfCodesInput: requireElement<html.InputElement>('numberOfCodes'),
      moduleSizeInput: requireElement<html.InputElement>('moduleSize'),
      paddingInput: requireElement<html.InputElement>('padding'),
      baseUrlInput: requireElement<html.InputElement>('baseUrl'),
      generateButton: requireElement<html.ButtonElement>('generateButton'),
      resetButton: requireElement<html.ButtonElement>('resetButton'),
      statusElement: requireElement<html.DivElement>('statusText'),
      progressElement: requireElement<html.DivElement>('progressText'),
      messageElement: requireElement<html.DivElement>('messageText'),
    );
  }

  void setDefaults({
    required int numberOfCodes,
    required int moduleSize,
    required int padding,
    required String baseUrl,
  }) {
    numberOfCodesInput.value = '$numberOfCodes';
    moduleSizeInput.value = '$moduleSize';
    paddingInput.value = '$padding';
    baseUrlInput.value = baseUrl;
  }

  void onGenerateClicked(Future<void> Function() action) {
    generateButton.onClick.listen((_) {
      action();
    });
  }

  void onResetClicked(void Function() action) {
    resetButton.onClick.listen((_) {
      action();
    });
  }

  GenerationRequest? readRequest() {
    final numberOfCodes = int.tryParse(numberOfCodesInput.value ?? '');
    final moduleSize = int.tryParse(moduleSizeInput.value ?? '');
    final padding = int.tryParse(paddingInput.value ?? '');
    final baseUrl = (baseUrlInput.value ?? '').trim();

    if (numberOfCodes == null || numberOfCodes <= 0) {
      setError('Number of QR Codes must be a positive integer.');
      return null;
    }

    if (moduleSize == null || moduleSize <= 0) {
      setError('Module Size must be a positive integer.');
      return null;
    }

    if (padding == null || padding < 0) {
      setError('Padding must be zero or a positive integer.');
      return null;
    }

    if (baseUrl.isEmpty) {
      setError('Base URL is required.');
      return null;
    }

    return GenerationRequest(
      baseUrl: baseUrl,
      numberOfCodes: numberOfCodes,
      moduleSize: moduleSize,
      padding: padding,
    );
  }

  void setBusy(bool isBusy) {
    generateButton.disabled = isBusy;
    resetButton.disabled = isBusy;
  }

  void setStatus(String text) {
    statusElement.text = text;
  }

  void setProgress(String text) {
    progressElement.text = text;
  }

  void setSuccess(String text) {
    messageElement
      ..text = text
      ..className = 'message success';
  }

  void setError(String text) {
    messageElement
      ..text = text
      ..className = 'message error';
  }

  void clearMessages() {
    progressElement.text = '';
    messageElement
      ..text = ''
      ..className = 'message';
  }
}