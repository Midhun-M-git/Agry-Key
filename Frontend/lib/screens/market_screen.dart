import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_state.dart';
import '../services/market_service.dart';
import '../utils/localization.dart';
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
        errorMessage = 'Unable to load market prices. Please try again.';
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
    final location = ref.watch(locationProvider).userLocation;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(L10n.get(
          'Market Prices',
          'മാർക്കറ്റ് വിലകൾ',
          'बाज़ार मूल्य',
          'சந்தை விலைகள்',
        )),
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.store, color: Colors.green),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'AGRI KEY Market',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Live mandi prices from the market service.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.green),
                title: Text(location.isEmpty ? 'Location Not Set' : location),
              ),
            ),
            const SizedBox(height: 15),
            VoiceTextField(
              controller: searchController,
              hintText: L10n.get(
                'Search Crop',
                'വിള തിരയുക',
                'फसल खोजें',
                'பயிரைத் தேடுங்கள்',
              ),
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text('No market prices found.')),
              )
            else
              ...prices.map(_marketCard),
          ],
        ),
      ),
    );
  }

  Widget _marketCard(MarketPrice marketPrice) {
    final change = marketPrice.changePercent;
    final changeText = change == null
        ? '—'
        : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.agriculture, color: Colors.green),
        ),
        title: Text(
          marketPrice.crop,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '₹${marketPrice.price.toStringAsFixed(2)} / ${marketPrice.unit}'
          '${marketPrice.mandi == null ? '' : '\n${marketPrice.mandi}'}',
        ),
        trailing: Text(
          changeText,
          style: TextStyle(
            color: marketPrice.isUp ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
