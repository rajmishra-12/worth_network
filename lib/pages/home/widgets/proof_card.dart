import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worth_network/core/bloc_observer/locale_cubit.dart';
import 'package:worth_network/core/model/home/evidence_model.dart';
import 'package:worth_network/core/theme/app_colors.dart';
import 'package:worth_network/core/theme/app_size.dart';
import 'package:worth_network/core/theme/app_text.dart';
import 'package:worth_network/core/utils/app_localizations.dart';
import 'package:worth_network/pages/home/widgets/in_app_document_viewer.dart';

class ProofCard extends StatelessWidget {
  final String? proofType; // 'photo', 'image', 'document', 'audio', 'text', 'link'
  final String? proofUrl;  // Remote URL or local path
  final File? localFile;   // Local File when uploading
  final String? textProof; // Text note content
  final EvidenceModel? evidence; // Single EvidenceModel
  final List<EvidenceModel>? evidences; // Multi-evidence items list
  final VoidCallback? onRemove; // Optional remove callback during upload
  final Function(int index)? onRemoveAtIndex; // Optional index-based remove callback for carousel

  const ProofCard({
    super.key,
    this.proofType,
    this.proofUrl,
    this.localFile,
    this.textProof,
    this.evidence,
    this.evidences,
    this.onRemove,
    this.onRemoveAtIndex,
  });

  @override
  Widget build(BuildContext context) {
    // If a list of evidence items is passed:
    if (evidences != null && evidences!.isNotEmpty) {
      if (evidences!.length == 1) {
        return ProofCard(
          evidence: evidences![0],
          onRemove: onRemoveAtIndex != null ? () => onRemoveAtIndex!(0) : onRemove,
        );
      }
      return _EvidenceCarousel(
        evidences: evidences!,
        onRemove: onRemove,
        onRemoveAtIndex: onRemoveAtIndex,
      );
    }

    final type = (evidence?.type ?? proofType)?.toLowerCase();
    final url = evidence?.url ?? proofUrl;
    final file = evidence?.localFile ?? localFile;
    final textContent = evidence?.text ?? textProof;

    if (type == null && file == null && (textContent == null || textContent.isEmpty) && url == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<LocaleCubit, String>(
      builder: (context, localeCode) {
        final loc = AppLocalizations(localeCode);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: AppSize.paddingS),
          decoration: BoxDecoration(
            color: AppColors.grey900,
            borderRadius: BorderRadius.circular(AppSize.radiusL),
            border: Border.all(color: AppColors.grey800),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header line with proof type badge & remove button if uploading
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSize.paddingM,
                  AppSize.paddingS,
                  AppSize.paddingM,
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getIconForType(type),
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTitleForType(type, loc),
                          style: CustomTextStyle.size12W600(color: AppColors.primary),
                        ),
                      ],
                    ),
                    if (onRemove != null)
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.grey400, size: 18),
                        onPressed: onRemove,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSize.spacingS),

              // Content according to type
              if (type == 'photo' || type == 'image')
                _ImageProofViewer(
                  proofUrl: url,
                  localFile: file,
                )
              else if (type == 'document')
                _DocumentProofViewer(
                  proofUrl: url,
                  localFile: file,
                  loc: loc,
                )
              else if (type == 'audio')
                _AudioProofPlayer(
                  proofUrl: url,
                  localFile: file,
                  loc: loc,
                )
              else if (type == 'link')
                _LinkProofViewer(
                  evidence: evidence,
                  fallbackUrl: url,
                  loc: loc,
                )
              else if (type == 'text' || (textContent != null && textContent.isNotEmpty))
                _TextProofViewer(textProof: textContent),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'photo':
      case 'image':
        return Icons.image_outlined;
      case 'document':
        return Icons.description_outlined;
      case 'audio':
        return Icons.mic_none_outlined;
      case 'link':
        return Icons.link_rounded;
      case 'text':
        return Icons.format_quote;
      default:
        return Icons.verified_outlined;
    }
  }

  String _getTitleForType(String? type, AppLocalizations loc) {
    switch (type) {
      case 'photo':
      case 'image':
        return loc.translate('proof_photo');
      case 'document':
        return loc.translate('proof_document');
      case 'audio':
        return loc.translate('proof_audio');
      case 'link':
        return 'Link Evidence';
      case 'text':
        return loc.translate('proof_text');
      default:
        return loc.translate('evidence_title');
    }
  }
}

// ----------------------------------------------------------------------
// Image Proof Viewer with Shimmer Loading & Tap to Fullscreen
// ----------------------------------------------------------------------
class _ImageProofViewer extends StatelessWidget {
  final String? proofUrl;
  final File? localFile;

  const _ImageProofViewer({this.proofUrl, this.localFile});

  void _openFullScreenImage(BuildContext context, ImageProvider imageProvider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSize.paddingM),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSize.radiusL),
                child: Image(image: imageProvider, fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.white100, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (localFile != null) {
      return GestureDetector(
        onTap: () => _openFullScreenImage(context, FileImage(localFile!)),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSize.radiusL)),
          child: Image.file(
            localFile!,
            height: 190,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (proofUrl != null && proofUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: () => _openFullScreenImage(context, NetworkImage(proofUrl!)),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppSize.radiusL)),
          child: CachedNetworkImage(
            imageUrl: proofUrl!,
            height: 190,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: AppColors.grey800,
              highlightColor: AppColors.grey700,
              child: Container(
                height: 190,
                width: double.infinity,
                color: AppColors.grey800,
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 180,
              color: AppColors.grey800,
              child: const Center(
                child: Icon(Icons.broken_image_outlined, color: AppColors.grey500, size: 40),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ----------------------------------------------------------------------
// Document Proof Viewer with Shimmer Loading & Open URL / File Action
// ----------------------------------------------------------------------
class _DocumentProofViewer extends StatelessWidget {
  final String? proofUrl;
  final File? localFile;
  final AppLocalizations loc;

  const _DocumentProofViewer({
    this.proofUrl,
    this.localFile,
    required this.loc,
  });

  void _openDocumentInApp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppDocumentViewerScreen(
          proofUrl: proofUrl,
          localFile: localFile,
          title: _getFileName(),
        ),
      ),
    );
  }

  Future<void> _openDocument(BuildContext context) async {
    _openDocumentInApp(context);
  }

  String _getFileName() {
    if (localFile != null) {
      final name = localFile!.path.split('/').last;
      return name.isNotEmpty ? name : 'Action Document.pdf';
    }
    if (proofUrl != null && proofUrl!.isNotEmpty) {
      final raw = proofUrl!.split('/').last;
      if (raw.contains('action_proofs') || raw.contains('_') || raw.length > 25) {
        return 'Action Document.pdf';
      }
      return raw;
    }
    return 'Action Document.pdf';
  }

  String _getFileExtension() {
    final name = _getFileName();
    if (name.contains('.')) {
      return name.split('.').last.toUpperCase();
    }
    return 'DOC';
  }

  String _getFileSizeString() {
    if (localFile != null && localFile!.existsSync()) {
      final bytes = localFile!.lengthSync();
      if (bytes >= 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return 'PDF / Document';
  }

  @override
  Widget build(BuildContext context) {
    final fileName = _getFileName();
    final fileExt = _getFileExtension();
    final fileSize = _getFileSizeString();

    return Padding(
      padding: const EdgeInsets.all(AppSize.paddingM),
      child: Container(
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey800,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.grey700),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSize.radiusM),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.picture_as_pdf, color: AppColors.info, size: 28),
                  const SizedBox(height: 2),
                  Text(
                    fileExt,
                    style: CustomTextStyle.size10W600(color: AppColors.info),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSize.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: CustomTextStyle.size14W600(color: AppColors.white100),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fileSize,
                    style: CustomTextStyle.size12W400(color: AppColors.grey400),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSize.spacingS),
            ElevatedButton.icon(
              onPressed: () => _openDocument(context),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: Text(
                loc.translate('btn_next') == 'Suivant' ? 'Ouvrir' : 'Open',
                style: CustomTextStyle.size12W600(color: AppColors.black100),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.black100,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Audio Proof Player Widget with Real-Time Playback & Seek Slider
// ----------------------------------------------------------------------
class _AudioProofPlayer extends StatefulWidget {
  final String? proofUrl;
  final File? localFile;
  final AppLocalizations loc;

  const _AudioProofPlayer({
    this.proofUrl,
    this.localFile,
    required this.loc,
  });

  @override
  State<_AudioProofPlayer> createState() => _AudioProofPlayerState();
}

class _AudioProofPlayerState extends State<_AudioProofPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = false;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() => _duration = d);
      }
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => _position = p);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _isLoading = true);
        if (widget.localFile != null) {
          await _audioPlayer.play(DeviceFileSource(widget.localFile!.path));
        } else if (widget.proofUrl != null && widget.proofUrl!.isNotEmpty) {
          await _audioPlayer.play(UrlSource(widget.proofUrl!));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio play error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(AppSize.paddingM),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM),
          decoration: BoxDecoration(
            color: AppColors.grey800,
            borderRadius: BorderRadius.circular(AppSize.radiusM),
            border: Border.all(color: AppColors.grey700),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSize.spacingM),
              Text(
                'Loading audio...',
                style: CustomTextStyle.size13W500(color: AppColors.grey400),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSize.paddingM),
      child: Container(
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey800,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.grey700),
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppColors.black100,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppSize.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.loc.translate('proof_audio'),
                            style: CustomTextStyle.size14W600(color: AppColors.white100),
                          ),
                          Text(
                            '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                            style: CustomTextStyle.size12W400(color: AppColors.grey400),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.grey700,
                          thumbColor: AppColors.primary,
                        ),
                        child: Slider(
                          value: _position.inSeconds.toDouble().clamp(
                                0.0,
                                _duration.inSeconds > 0
                                    ? _duration.inSeconds.toDouble()
                                    : 1.0,
                              ),
                          max: _duration.inSeconds > 0
                              ? _duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (value) async {
                            final seekPos = Duration(seconds: value.toInt());
                            await _audioPlayer.seek(seekPos);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Text Proof Viewer Widget
// ----------------------------------------------------------------------
class _TextProofViewer extends StatelessWidget {
  final String? textProof;

  const _TextProofViewer({this.textProof});

  @override
  Widget build(BuildContext context) {
    if (textProof == null || textProof!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppSize.paddingM),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSize.paddingM),
        decoration: BoxDecoration(
          color: AppColors.grey800,
          borderRadius: BorderRadius.circular(AppSize.radiusM),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.format_quote, color: AppColors.accent, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                textProof!,
                style: CustomTextStyle.size14W400(color: AppColors.grey200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Link Proof Viewer Widget with Preview Thumbnail & Browser Launcher
// ----------------------------------------------------------------------
class _LinkProofViewer extends StatelessWidget {
  final EvidenceModel? evidence;
  final String? fallbackUrl;
  final AppLocalizations loc;

  const _LinkProofViewer({
    this.evidence,
    this.fallbackUrl,
    required this.loc,
  });

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL $url: $e');
    }
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetUrl = evidence?.url ?? fallbackUrl;
    if (targetUrl == null || targetUrl.isEmpty) return const SizedBox.shrink();

    final title = evidence?.title ?? targetUrl;
    final imageUrl = evidence?.imageUrl;
    final description = evidence?.description;
    final domain = _getDomain(targetUrl);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.paddingM, vertical: AppSize.paddingS),
      child: GestureDetector(
        onTap: () => _launchUrl(targetUrl),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.grey800,
            borderRadius: BorderRadius.circular(AppSize.radiusM),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview Thumbnail Image if available
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSize.radiusM)),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: AppColors.grey900,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    ),
                    errorWidget: (context, url, error) => const SizedBox.shrink(),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Site Domain Tag & Open Link Button Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.language_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              domain,
                              style: CustomTextStyle.size12W500(color: AppColors.primary),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _launchUrl(targetUrl),
                          icon: const Icon(Icons.open_in_new, size: 12),
                          label: Text(
                            'Open Link',
                            style: CustomTextStyle.size11W600(color: AppColors.black100),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.black100,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Link Title
                    Text(
                      title,
                      style: CustomTextStyle.size13W600(color: AppColors.white100),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Link Description if present
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: CustomTextStyle.size11W400(color: AppColors.grey400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Horizontal Carousel Widget for Multiple Evidence Attachments
// ----------------------------------------------------------------------
class _EvidenceCarousel extends StatefulWidget {
  final List<EvidenceModel> evidences;
  final VoidCallback? onRemove;
  final Function(int index)? onRemoveAtIndex;

  const _EvidenceCarousel({
    required this.evidences,
    this.onRemove,
    this.onRemoveAtIndex,
  });

  @override
  State<_EvidenceCarousel> createState() => _EvidenceCarouselState();
}

class _EvidenceCarouselState extends State<_EvidenceCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 295,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.evidences.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = widget.evidences[index];
                  final removeItem = widget.onRemoveAtIndex != null
                      ? () => widget.onRemoveAtIndex!(index)
                      : (widget.onRemove != null && index == 0 ? widget.onRemove : null);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ProofCard(
                      evidence: item,
                      onRemove: removeItem,
                    ),
                  );
                },
              ),
              // Top-right counter badge (e.g., 1 / 2)
              Positioned(
                top: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey700),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.collections_outlined, size: 13, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(
                        '${_currentPage + 1} / ${widget.evidences.length}',
                        style: CustomTextStyle.size12W600(color: AppColors.white100),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.evidences.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? AppColors.primary : AppColors.grey700,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
