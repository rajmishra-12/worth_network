// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class ContentModerationService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   /// Cached banned words
//   List<String>? _cachedWords;

//   /// 🔒 Local fallback list (used if Firestore fails OR before login)
//   static const List<String> _fallbackWords = [
//     // English profanity
//     "fuck","fucking","motherfucker","shit","bullshit","asshole","bitch",
//     "bastard","cunt","dick","pussy","cock","whore","slut","porn","sex",

//     // French profanity
//     "pute","salope","connard","connasse","enculé","bite","chatte","couille",
//     "porno","sexe",

//     // Self-harm / suicide
//     "suicide","kill myself","self harm","self-harm","die myself","end my life",
//     "me suicider","me tuer","me faire du mal","automutilation","finir ma vie",

//     // Hate / insults
//     "hate you","go die","stupid idiot","retard","moron","je te hais",
//     "va mourir","idiot","stupide","débile","attardé",

//     // Violence
//     "kill you","murder","rape","te tuer","meurtre","violer","viol",
//   ];

//   /// Loads banned words safely
//   Future<List<String>> _loadBannedWords() async {
//     if (_cachedWords != null) return _cachedWords!;

//     try {
//       final snap = await _firestore
//           .collection('moderationConfig')
//           .doc('bannedWords')
//           .get();

//       final data = snap.data();

//       /// If Firestore empty → still use fallback
//       final remote = List<String>.from(data?['words'] ?? []);

//       _cachedWords = remote.isNotEmpty ? remote : _fallbackWords;
//     } catch (e) {
//       debugPrint("⚠️ Moderation fallback used (Firestore blocked): $e");

//       /// 🔐 NEVER crash → always fallback
//       _cachedWords = _fallbackWords;
//     }

//     return _cachedWords!;
//   }

//   /// Checks if text contains banned content
//   Future<bool> containsBannedWord(String text) async {
//     final normalized = normalizeText(text);
//     final words = await _loadBannedWords();

//     debugPrint("MODERATION CHECK:");
//     debugPrint("TEXT: $normalized");
//     debugPrint("BANNED WORDS COUNT: ${words.length}");

//     for (final banned in words) {
//       if (normalized.contains(banned.toLowerCase())) {
//         return true;
//       }
//     }
//     return false;
//   }
// }




// String normalizeText(String input) {
//   return input
//       .toLowerCase()
//       .trim()
//       .replaceAll(RegExp(r'[^\w\s]'), '');
// }
// class ModerationUiHelper {
//   static Future<bool> validateAndShow(
//     BuildContext context,
//     String text, {
//     String message = "Votre commentaire contient un mot interdit.",
//     bool closeBeforeShow = false, 
//   }) async {
//     final hasBadWord =
//         await ContentModerationService().containsBannedWord(text);

//     if (!hasBadWord) return true;

   
//     if (closeBeforeShow) {
//       Navigator.of(context).maybePop();
//       await Future.delayed(const Duration(milliseconds: 150));
//     }

//     ScaffoldMessenger.of(
//       Navigator.of(context, rootNavigator: true).context,
//     ).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );

//     return false;
//   }
// }
