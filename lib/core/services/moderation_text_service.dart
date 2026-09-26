import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModerationTextService {
  static final ModerationTextService _instance = ModerationTextService._internal();
  factory ModerationTextService() => _instance;
  ModerationTextService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initial fallback list of prohibited words
  final Set<String> _blockedWords = {
    'abuse',
    'abusive',
    'harass',
    'harassment',
    'hate',
    'hatespeech',
    'racist',
    'sexist',
    'scam',
    'spam',
    'threat',
    'threaten',
    'violence',
    'fuck',
    'shit',
    'bitch',
    'bastard',
    'asshole',
    'dick',
    'pussy',
    'nigger',
    'faggot',
    'cunt',
  };

  bool _isInitialized = false;
  StreamSubscription? _subscription;

  /// Initialize real-time sync with Firebase moderationSettings/blockedWords
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      _subscription = _firestore
          .collection('moderationSettings')
          .doc('blockedWords')
          .snapshots()
          .listen(
        (snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final List<dynamic>? wordsList = snapshot.data()?['words'] as List<dynamic>?;
            if (wordsList != null) {
              _blockedWords.clear();
              for (var w in wordsList) {
                final cleaned = w.toString().trim().toLowerCase();
                if (cleaned.isNotEmpty) {
                  _blockedWords.add(cleaned);
                }
              }
            }
          }
        },
        onError: (e) {
          print('ModerationTextService Firestore stream warning: $e');
        },
      );
    } catch (e) {
      print('ModerationTextService init error: $e');
    }
  }

  /// Check text for prohibited words. Returns error message if found, or null if clean.
  Future<String?> checkText(String? text) async {
    if (text == null || text.trim().isEmpty) return null;

    initialize();

    // Fetch latest blocked words if local cache is empty
    if (_blockedWords.isEmpty) {
      try {
        final doc = await _firestore.collection('moderationSettings').doc('blockedWords').get();
        if (doc.exists && doc.data() != null) {
          final List<dynamic>? wordsList = doc.data()?['words'] as List<dynamic>?;
          if (wordsList != null) {
            for (var w in wordsList) {
              final cleaned = w.toString().trim().toLowerCase();
              if (cleaned.isNotEmpty) _blockedWords.add(cleaned);
            }
          }
        }
      } catch (e) {
        print('Fallback blocked words fetch error: $e');
      }
    }

    final lowerText = text.toLowerCase();

    for (final word in _blockedWords) {
      if (word.isEmpty) continue;
      
      // Use regex with word boundary \b to prevent matching substrings inside innocent words
      // Escaping special regex characters in the blocked word
      final pattern = r'\b' + RegExp.escape(word) + r'\b';
      final regex = RegExp(pattern, caseSensitive: false);

      if (regex.hasMatch(lowerText)) {
        return 'Please remove inappropriate language ("$word") before continuing.';
      }
    }

    return null;
  }

  /// Get active list of blocked words
  Set<String> get currentBlockedWords => Set.from(_blockedWords);

  void dispose() {
    _subscription?.cancel();
    _isInitialized = false;
  }
}
