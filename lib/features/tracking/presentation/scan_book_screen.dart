import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import '../models/reading_models.dart';
import '../providers/book_api_service.dart';
import '../providers/tracking_providers.dart';

class ScanBookScreen extends ConsumerStatefulWidget {
  const ScanBookScreen({super.key});

  @override
  ConsumerState<ScanBookScreen> createState() => _ScanBookScreenState();
}

class _ScanBookScreenState extends ConsumerState<ScanBookScreen> {
  final MobileScannerController _controller = MobileScannerController();
  final BookApiService _apiService = BookApiService();
  bool _isScanning = true;
  bool _isLoading = false;
  Map<String, dynamic>? _scannedBook;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _isLoading) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
          _isLoading = true;
        });

        final bookData = await _apiService.fetchBookByIsbn(barcode.rawValue!);

        if (mounted) {
          setState(() {
            _isLoading = false;
            _scannedBook = bookData;
          });

          if (bookData == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('책 정보를 찾을 수 없습니다. 다시 스캔해주세요.')),
            );
            // Resume scanning after a short delay if failed
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                setState(() => _isScanning = true);
              }
            });
          }
        }
        break; // Process only the first valid barcode
      }
    }
  }

  void _resetScan() {
    setState(() {
      _scannedBook = null;
      _isScanning = true;
    });
  }

  Future<void> _addToLibrary() async {
    if (_scannedBook == null) return;

    final shouldReplace = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('책 교체 확인'),
        content: const Text('현재 읽고 있는 책을 이 책으로 교체하시겠습니까?\n기존 독서 기록은 초기화됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('교체'),
          ),
        ],
      ),
    );

    if (shouldReplace == true && mounted) {
      final title = _scannedBook!['title'] ?? '제목 없음';
      final authors =
          (_scannedBook!['authors'] as List?)?.join(', ') ?? '저자 미상';
      final pageCount = _scannedBook!['pageCount'] as int? ?? 300;
      final thumbnail = _scannedBook!['imageLinks']?['thumbnail'] as String?;

      final newBook = ReadingBook(
        id: const Uuid().v4(),
        title: title,
        author: authors,
        totalPages: pageCount,
        currentPage: 0,
        coverUrl: thumbnail,
      );

      ref.read(readingTrackerProvider.notifier).setBook(newBook);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title 책이 서재에 추가되었습니다.')));
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('책 바코드 스캔')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                MobileScanner(controller: _controller, onDetect: _onDetect),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (!_isScanning && _scannedBook != null)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              color: Colors.white,
              child: _scannedBook == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '책 뒷면의 바코드를 스캔하세요',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '스캔 결과',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        if (_scannedBook!['imageLinks'] != null)
                          Center(
                            child: Image.network(
                              _scannedBook!['imageLinks']['thumbnail'] ?? '',
                              height: 120,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.book, size: 80),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          _scannedBook!['title'] ?? '제목 없음',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          (_scannedBook!['authors'] as List?)?.join(', ') ??
                              '저자 미상',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _resetScan,
                                child: const Text('다시 스캔'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: FilledButton(
                                onPressed: _addToLibrary,
                                child: const Text('서재에 추가'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
