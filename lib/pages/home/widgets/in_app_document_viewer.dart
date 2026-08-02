import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';

class InAppDocumentViewerScreen extends StatefulWidget {
  final String? proofUrl;
  final File? localFile;
  final String title;

  const InAppDocumentViewerScreen({
    super.key,
    this.proofUrl,
    this.localFile,
    this.title = 'Document Viewer',
  });

  @override
  State<InAppDocumentViewerScreen> createState() => _InAppDocumentViewerScreenState();
}

class _InAppDocumentViewerScreenState extends State<InAppDocumentViewerScreen> {
  File? _pdfFile;
  bool _isLoading = true;
  String? _errorMessage;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfViewController;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      if (widget.localFile != null && widget.localFile!.existsSync()) {
        setState(() {
          _pdfFile = widget.localFile;
          _isLoading = false;
        });
        return;
      }

      if (widget.proofUrl != null && widget.proofUrl!.isNotEmpty) {
        String downloadUrl = widget.proofUrl!;
        if (!downloadUrl.startsWith('http://') && !downloadUrl.startsWith('https://')) {
          downloadUrl = await FirebaseStorage.instance.ref(downloadUrl).getDownloadURL();
        }

        // Fetch file via CacheManager
        final file = await DefaultCacheManager().getSingleFile(downloadUrl);
        if (mounted) {
          setState(() {
            _pdfFile = file;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No document source provided.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load document: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.grey900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white100),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: CustomTextStyle.size16W600(color: AppColors.white100),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSize.paddingM),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.grey800,
                    borderRadius: BorderRadius.circular(AppSize.radiusS),
                  ),
                  child: Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: CustomTextStyle.size12W600(color: AppColors.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppSize.spacingM),
            Text(
              'Loading document inside app...',
              style: TextStyle(color: AppColors.grey400, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSize.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: AppSize.spacingM),
              Text(
                _errorMessage!,
                style: CustomTextStyle.size14W400(color: AppColors.grey300),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSize.spacingL),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadDocument();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.black100,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pdfFile != null) {
      return Stack(
        children: [
          PDFView(
            filePath: _pdfFile!.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? 0;
              });
            },
            onViewCreated: (PDFViewController controller) {
              _pdfViewController = controller;
            },
          ),
          if (_totalPages > 1)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey900.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppSize.radiusL),
                  border: Border.all(color: AppColors.grey800),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: AppColors.white100),
                      onPressed: _currentPage > 0
                          ? () => _pdfViewController?.setPage(_currentPage - 1)
                          : null,
                    ),
                    Text(
                      '${_currentPage + 1} / $_totalPages',
                      style: CustomTextStyle.size12W600(color: AppColors.white100),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: AppColors.white100),
                      onPressed: _currentPage < _totalPages - 1
                          ? () => _pdfViewController?.setPage(_currentPage + 1)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
