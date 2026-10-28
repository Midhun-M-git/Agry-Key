import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_state.dart';
import '../l10n/app_localizations.dart';
import '../services/market_service.dart';
import '../widgets/voice_text_field.dart';

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  final TextEditingController searchController = TextEditingController();
  final MarketService marketService = const MarketService();

  List<MarketPrice> prices = const [];
  bool isLoading = true;
  String? errorMessage;
  String activeCrop = '';

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPrices({String? crop}) async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
        if (crop != null) activeCrop = crop;
      });
    }

    try {
      final district = ref.read(locationProvider).district;
      final result = await marketService.fetchMandiPrices(
        district,
        crop ?? activeCrop,
      );
      if (!mounted) return;
      setState(() {
        prices = result;
        isLoading = false;
      });
    } on MarketServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error.message;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = context.l10n.isMalayalam
            ? 'വിപണി നിരക്കുകൾ ലഭ്യമാക്കാൻ സാധിച്ചില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.'
            : 'Unable to load market prices. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> _searchCrop(String query) async {
    final crop = query.trim();
    if (crop.isEmpty) {
      await _loadPrices(crop: '');
      return;
    }
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
        activeCrop = crop;
      });
    }
    try {
      final result = await marketService.searchCrops(crop);
      if (!mounted) return;
      setState(() {
        prices = result;
        isLoading = false;
      });
    } on MarketServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        errorMessage = error.message;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);
    final l10n = context.l10n;
    final location = ref.watch(locationProvider).userLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          l10n.marketTitle,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPrices(crop: activeCrop),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.store, color: Colors.green),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.isMalayalam ? 'അഗ്രി-കീ വിപണി' : 'Agry-Key Market',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.marketSubtitle,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: Text(
                  location.isEmpty ? (l10n.isMalayalam ? 'സ്ഥലം നൽകിയിട്ടില്ല' : 'Location Not Set') : location,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 15),
            VoiceTextField(
              controller: searchController,
              hintText: l10n.marketSearchHint,
              onSubmitted: _searchCrop,
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (errorMessage != null)
              _ErrorState(message: errorMessage!, onRetry: _loadPrices)
            else if (prices.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    l10n.marketPriceUnavailable,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              )
            else
              ...prices.map((p) => _marketCard(p, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _marketCard(MarketPrice marketPrice, AppLocalizations l10n) {
    final change = marketPrice.changePercent;
    final changeText = change == null
        ? '—'
        : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
    final sourceText = marketPrice.source ?? (l10n.isMalayalam ? 'അഗ്മാർക്ക്നെറ്റ് റഫറൻസ്' : 'APMC Market Reference');
    final dateText = marketPrice.observationDate ?? (l10n.isMalayalam ? 'രേഖപ്പെടുത്തിയ തീയതി' : 'Recorded Observation');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.agriculture, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        marketPrice.crop,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (marketPrice.mandi != null && marketPrice.mandi!.isNotEmpty)
                        Text(
                          marketPrice.mandi!,
                          style: const TextStyle(color: Colors.black87, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  changeText,
                  style: TextStyle(
                    color: (marketPrice.changePercent ?? 0) >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '₹${marketPrice.price.toStringAsFixed(2)} / ${marketPrice.unit}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1B5E20),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: marketPrice.isLive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: marketPrice.isLive ? Colors.green : Colors.grey.shade400,
                    ),
                  ),
                  child: Text(
                    marketPrice.isLive
                        ? (l10n.isMalayalam ? 'തത്സമയം' : 'LIVE')
                        : (l10n.isMalayalam ? 'റഫറൻസ്' : 'REFERENCE'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: marketPrice.isLive ? Colors.green.shade800 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Text(
              l10n.isMalayalam ? 'ഉറവിടം: $sourceText • $dateText' : 'Source: $sourceText • $dateText',
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: Colors.redAccent, size: 42),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.actionRetry),
          ),
        ],
      ),
    );
  }
}
