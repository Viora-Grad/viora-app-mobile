import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewPage({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _completed = false;
  bool _hasError = false;
  bool _pageLoaded = false;
  String? _errorMessage;
  String? _initialHost;
  bool _hasLeftInitialHost = false;
  String? _previousNonInitialHost;

  @override
  void initState() {
    super.initState();
    final initialUri = Uri.tryParse(widget.paymentUrl);
    _initialHost = initialUri?.host;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          if (mounted) setState(() => _isLoading = true);
          _checkCompletion(url);
        },
        onPageFinished: (_) {
          if (mounted) {
            _pageLoaded = true;
            setState(() => _isLoading = false);
          }
        },
        onNavigationRequest: (request) {
          return NavigationDecision.navigate;
        },
        onUrlChange: (change) {
          _checkCompletion(change.url ?? '');
        },
        onWebResourceError: (error) {
          if (!mounted || _pageLoaded) return;
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = error.description.isNotEmpty
                ? error.description
                : 'Failed to load payment page (${error.errorCode})';
          });
        },
      ))
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkCompletion(String url) {
    if (_completed) return;
    if (url.contains('google.com') || url.contains('success') || url.contains('completed')) {
      _onComplete();
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || _initialHost == null) return;
    if (!_pageLoaded) return;

    if (uri.host == _initialHost) {
      _hasLeftInitialHost = false;
      _previousNonInitialHost = null;
      return;
    }

    if (!_hasLeftInitialHost) {
      _hasLeftInitialHost = true;
      _previousNonInitialHost = uri.host;
      return;
    }

    if (_previousNonInitialHost != null && uri.host != _previousNonInitialHost) {
      _onComplete();
    }
  }

  void _onComplete() {
    if (_completed) return;
    _completed = true;
    if (!mounted) return;
    setState(() {});
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_completed,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _completed) Navigator.of(context).pop(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1A1A2E), size: 22),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          title: Text(
            _completed
                ? 'Payment Complete'
                : _hasError
                    ? 'Payment Error'
                    : 'Complete Payment',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          centerTitle: true,
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0D7C66),
                  ),
                ),
              ),
          ],
        ),
        body: _hasError ? _buildError() : _buildWebView(),
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_completed)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.symmetric(
                  vertical: 36,
                  horizontal: 28,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Color(0xFF0D7C66),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Success in charging the wallet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF0D7C66),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Page Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D7C66),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
