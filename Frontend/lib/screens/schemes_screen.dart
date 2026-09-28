import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../models/scheme.dart';
import '../services/schemes_service.dart';
import '../utils/localization.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/scheme_card.dart';

class SchemesScreen extends ConsumerStatefulWidget {
  const SchemesScreen({super.key});

  @override
  ConsumerState<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends ConsumerState<SchemesScreen> {
  List<GovernmentScheme> _schemes = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedSector;

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await SchemesService.fetchSchemes(
        state: AppState.userState.isNotEmpty ? AppState.userState : 'Kerala',
        sector: _selectedSector,
      );
      if (mounted) {
        setState(() {
          _schemes = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showSchemeDetails(GovernmentScheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          scheme.code,
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        scheme.level,
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    scheme.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    scheme.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                  ),
                  const Divider(height: 32),
                  if (scheme.benefits.isNotEmpty) ...[
                    const Text('Benefits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...scheme.benefits.map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, size: 16, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(b, style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (scheme.eligibility.isNotEmpty) ...[
                    const Text('Eligibility', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...scheme.eligibility.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.verified_user_outlined, size: 16, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(child: Text(e, style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        )),
                    const SizedBox(height: 16),
                  ],
                  if (scheme.documents.isNotEmpty) ...[
                    const Text('Required Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...scheme.documents.map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.description_outlined, size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(child: Text(d, style: const TextStyle(fontSize: 13))),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Close', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          L10n.get(
            "Government Schemes",
            "സർക്കാർ പദ്ധതികൾ",
            "सरकारी योजनाएँ",
            "அரசுத் திட்டங்கள்",
          ),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadSchemes,
            tooltip: 'Refresh Schemes',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('All Sectors', null),
                _buildFilterChip('Crops', 'CROP'),
                _buildFilterChip('Dairy & Livestock', 'LIVESTOCK'),
                _buildFilterChip('Poultry', 'POULTRY'),
                _buildFilterChip('Fisheries', 'AQUACULTURE'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Fetching state and central schemes...')
                : _errorMessage != null && _schemes.isEmpty
                    ? AppErrorWidget(
                        message: _errorMessage!,
                        onRetry: _loadSchemes,
                      )
                    : _schemes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text('No schemes found', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadSchemes,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: _schemes.length,
                              itemBuilder: (context, index) {
                                final scheme = _schemes[index];
                                return SchemeCard(
                                  scheme: scheme,
                                  onTap: () => _showSchemeDetails(scheme),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? sector) {
    final isSelected = _selectedSector == sector;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.green.shade100,
        checkmarkColor: Colors.green.shade900,
        labelStyle: TextStyle(
          color: isSelected ? Colors.green.shade900 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) {
          setState(() {
            _selectedSector = sector;
          });
          _loadSchemes();
        },
      ),
    );
  }
}