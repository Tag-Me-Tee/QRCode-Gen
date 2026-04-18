import 'dart:math';

class IdGenerator {
  static const _chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final Random _random;

  IdGenerator({Random? random}) : _random = random ?? Random();

  // Keeps the existing ID strategy: 8 chars from a-z and 0-9.
  String generateCandidateId() {
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => _chars.codeUnitAt(_random.nextInt(_chars.length)),
      ),
    );
  }

  Future<String> generateUniqueId(
    Future<bool> Function(String id) isIdAvailable,
  ) async {
    String uniqueId;
    do {
      uniqueId = generateCandidateId();
    } while (!await isIdAvailable(uniqueId));

    return uniqueId;
  }
}
