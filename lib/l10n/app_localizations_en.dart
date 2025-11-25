// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Booklog';

  @override
  String get tabTracking => 'Tracking';

  @override
  String get tabNotes => 'Notes';

  @override
  String get tabCommunity => 'Community';

  @override
  String get navTracking => 'Tracking';

  @override
  String get navNotes => 'Notes';

  @override
  String get navCommunity => 'Community';

  @override
  String get scanBook => 'Scan Book';

  @override
  String get scanTitle => 'Scan Book Barcode';

  @override
  String get scanPrompt => 'Scan the barcode on the back of the book';

  @override
  String get scanResult => 'Scan Result';

  @override
  String get rescan => 'Rescan';

  @override
  String get addToLibrary => 'Add to Library';

  @override
  String get unknownTitle => 'Unknown Title';

  @override
  String get unknownAuthor => 'Unknown Author';

  @override
  String get reviews => 'Reviews';

  @override
  String get comments => 'Comments';

  @override
  String get noComments => 'No comments yet.\nBe the first to leave one!';

  @override
  String get writeComment => 'Write a comment...';

  @override
  String get featurePending => 'This feature is coming soon.';
}
