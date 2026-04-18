import 'firebase_link_read_service.dart';

class IdAvailabilityService {
  final Set<String> _localIds;
  final FirebaseLinkReadService _firebaseLinkReadService;

  IdAvailabilityService(
    this._localIds, {
    FirebaseLinkReadService? firebaseLinkReadService,
  }) : _firebaseLinkReadService =
           firebaseLinkReadService ?? FirebaseLinkReadService();

  Future<bool> isIdAvailable(String id) async {
    // Firebase is the primary source of truth.
    final existsInFirebase = await _firebaseLinkReadService.idExists(id);
    if (existsInFirebase) {
      return false;
    }

    // Local IDs remain a secondary safeguard, including same-run duplicates.
    if (_localIds.contains(id)) {
      return false;
    }

    return true;
  }

  void markIdAsUsed(String id) {
    _localIds.add(id);
  }
}
