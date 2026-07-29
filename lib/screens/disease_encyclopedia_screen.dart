import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../design_system/nursemate_design_system.dart';

final Uri kAsanDiseaseEncyclopediaUri = Uri.parse(
  'https://www.amc.seoul.kr/asan/main.do',
);

typedef DiseaseWebViewErrorCallback = void Function(Object error);

abstract interface class DiseaseWebViewClient {
  void configure({
    required VoidCallback onPageStarted,
    required VoidCallback onPageFinished,
    required DiseaseWebViewErrorCallback onError,
  });

  Future<void> load(Uri uri);

  Future<void> reload();

  Widget buildView();
}

class WebViewFlutterDiseaseClient implements DiseaseWebViewClient {
  late final WebViewController _controller;

  @override
  void configure({
    required VoidCallback onPageStarted,
    required VoidCallback onPageFinished,
    required DiseaseWebViewErrorCallback onError,
  }) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(NurseMateColors.surface)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => onPageStarted(),
          onPageFinished: (_) => onPageFinished(),
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return;
            onError(error);
          },
        ),
      );
  }

  @override
  Widget buildView() => WebViewWidget(controller: _controller);

  @override
  Future<void> load(Uri uri) => _controller.loadRequest(uri);

  @override
  Future<void> reload() => _controller.reload();
}

class UnsupportedDiseaseWebViewClient implements DiseaseWebViewClient {
  DiseaseWebViewErrorCallback? _onError;

  @override
  void configure({
    required VoidCallback onPageStarted,
    required VoidCallback onPageFinished,
    required DiseaseWebViewErrorCallback onError,
  }) {
    _onError = onError;
  }

  @override
  Widget buildView() => const SizedBox.expand();

  @override
  Future<void> load(Uri uri) async {
    _onError?.call(UnsupportedError('이 플랫폼에서는 WebView를 지원하지 않습니다.'));
  }

  @override
  Future<void> reload() => load(kAsanDiseaseEncyclopediaUri);
}

DiseaseWebViewClient createDiseaseWebViewClient() {
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    return WebViewFlutterDiseaseClient();
  }
  return UnsupportedDiseaseWebViewClient();
}

class DiseaseEncyclopediaScreen extends StatefulWidget {
  const DiseaseEncyclopediaScreen({super.key, this.webViewClient});

  final DiseaseWebViewClient? webViewClient;

  @override
  State<DiseaseEncyclopediaScreen> createState() =>
      _DiseaseEncyclopediaScreenState();
}

class _DiseaseEncyclopediaScreenState
    extends State<DiseaseEncyclopediaScreen> {
  late final DiseaseWebViewClient _webViewClient;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _webViewClient = widget.webViewClient ?? createDiseaseWebViewClient();
    _webViewClient.configure(
      onPageStarted: _handlePageStarted,
      onPageFinished: _handlePageFinished,
      onError: _handleError,
    );
    _loadInitialPage();
  }

  Future<void> _loadInitialPage() async {
    try {
      await _webViewClient.load(kAsanDiseaseEncyclopediaUri);
    } on Object catch (error) {
      _handleError(error);
    }
  }

  void _handlePageStarted() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
  }

  void _handlePageFinished() {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _handleError(Object _) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = true;
    });
  }

  Future<void> _retry() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      await _webViewClient.reload();
    } on Object catch (error) {
      _handleError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NurseMateColors.background,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('diseaseWebViewBackButton'),
          tooltip: '뒤로가기',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('질환백과'),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: NurseMateMotion.standard,
          switchInCurve: NurseMateMotion.curve,
          switchOutCurve: NurseMateMotion.curve,
          child: _hasError
              ? _DiseaseLoadError(onRetry: _retry)
              : Stack(
                  key: const Key('diseaseWebViewContent'),
                  children: [
                    Positioned.fill(child: _webViewClient.buildView()),
                    if (_isLoading)
                      const Positioned.fill(
                        child: ColoredBox(
                          color: NurseMateColors.background,
                          child: Center(
                            child: CircularProgressIndicator(
                              key: Key('diseaseWebViewLoading'),
                              color: NurseMateColors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DiseaseLoadError extends StatelessWidget {
  const _DiseaseLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('diseaseWebViewError'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(NurseMateSpacing.page),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: NurseMateCard(
            radius: NurseMateRadii.panel,
            padding: const EdgeInsets.all(NurseMateSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: NurseMateColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: NurseMateColors.primary,
                    size: 34,
                  ),
                ),
                const SizedBox(height: NurseMateSpacing.lg),
                const Text(
                  '페이지를 불러오지 못했어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: NurseMateColors.navy,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: NurseMateSpacing.sm),
                const Text(
                  '인터넷 연결을 확인한 뒤 다시 시도해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: NurseMateColors.textSecondary,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: NurseMateSpacing.xl),
                NurseMatePrimaryButton(
                  key: const Key('diseaseWebViewRetryButton'),
                  label: '다시 시도',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
