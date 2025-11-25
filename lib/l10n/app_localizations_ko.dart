// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '북로그';

  @override
  String get tabTracking => '독서 분량';

  @override
  String get tabNotes => '독서 메모';

  @override
  String get tabCommunity => '커뮤니티';

  @override
  String get navTracking => '분량';

  @override
  String get navNotes => '메모';

  @override
  String get navCommunity => '커뮤니티';

  @override
  String get scanBook => '책 스캔';

  @override
  String get scanTitle => '책 바코드 스캔';

  @override
  String get scanPrompt => '책 뒷면의 바코드를 스캔하세요';

  @override
  String get scanResult => '스캔 결과';

  @override
  String get rescan => '다시 스캔';

  @override
  String get addToLibrary => '서재에 추가';

  @override
  String get unknownTitle => '제목 없음';

  @override
  String get unknownAuthor => '저자 미상';

  @override
  String get reviews => '리뷰';

  @override
  String get comments => '댓글';

  @override
  String get noComments => '아직 댓글이 없습니다.\n첫 번째 댓글을 남겨보세요!';

  @override
  String get writeComment => '댓글을 입력하세요...';

  @override
  String get featurePending => '준비 중인 기능입니다.';
}
