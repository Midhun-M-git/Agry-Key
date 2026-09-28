import 'package:flutter/material.dart';
import '../services/blockchain_service.dart';
import '../utils/localization.dart';

class BlockchainVerifyScreen extends StatefulWidget {
  const BlockchainVerifyScreen({super.key});

  @override
  State<BlockchainVerifyScreen> createState() => _BlockchainVerifyScreenState();
}

class _BlockchainVerifyScreenState extends State<BlockchainVerifyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BlockchainService _blockchainService = const BlockchainService();

  // Fertilizer verify state
  final TextEditingController _fertBatchController =
      TextEditingController(text: "IFFCO-TEST-2026-01");
  final TextEditingController _dealerPriceController = TextEditingController();
  bool _loadingFert = false;
  Map<String, dynamic>? _fertResult;
  String? _fertError;

  // Produce verify state
  final TextEditingController _produceBatchController = TextEditingController();
  bool _loadingProduce = false;
  Map<String, dynamic>? _produceResult;
  String? _produceError;

  // Record sale state
  final TextEditingController _saleBatchIdController = TextEditingController();
  final TextEditingController _saleQtyController = TextEditingController();
  final TextEditingController _salePriceController = TextEditingController();
  final TextEditingController _buyerDetailsController = TextEditingController();
  String _selectedTier = "PLATFORM_VERIFIED";
  bool _loadingSale = false;
  Map<String, dynamic>? _saleResult;
  String? _saleError;

  // Ledger state
  bool _loadingLedger = false;
  List<Map<String, dynamic>> _ledgerBlocks = [];
  String? _ledgerError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fertBatchController.dispose();
    _dealerPriceController.dispose();
    _produceBatchController.dispose();
    _saleBatchIdController.dispose();
    _saleQtyController.dispose();
    _salePriceController.dispose();
    _buyerDetailsController.dispose();
    super.dispose();
  }

  Future<void> _verifyFertilizer() async {
    final batch = _fertBatchController.text.trim();
    if (batch.isEmpty) return;

    setState(() {
      _loadingFert = true;
      _fertResult = null;
      _fertError = null;
    });

    try {
      final dealerPrice = double.tryParse(_dealerPriceController.text.trim());
      final res = await _blockchainService.verifyFertilizer(
        batch,
        dealerAskingPrice: dealerPrice,
      );
      if (!mounted) return;
      setState(() {
        _fertResult = res;
        _loadingFert = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fertError = e.toString().replaceFirst("Exception: ", "");
        _loadingFert = false;
      });
    }
  }

  Future<void> _verifyProduce() async {
    final id = _produceBatchController.text.trim();
    if (id.isEmpty) return;

    setState(() {
      _loadingProduce = true;
      _produceResult = null;
      _produceError = null;
    });

    try {
      final res = await _blockchainService.verifyProduce(id);
      if (!mounted) return;
      setState(() {
        _produceResult = res;
        _loadingProduce = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _produceError = e.toString().replaceFirst("Exception: ", "");
        _loadingProduce = false;
      });
    }
  }

  Future<void> _recordSale() async {
    final batchId = _saleBatchIdController.text.trim();
    final qty = double.tryParse(_saleQtyController.text.trim());
    final price = double.tryParse(_salePriceController.text.trim());

    if (batchId.isEmpty || qty == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required sale fields.")),
      );
      return;
    }

    setState(() {
      _loadingSale = true;
      _saleResult = null;
      _saleError = null;
    });

    try {
      final res = await _blockchainService.recordSale(
        produceBatchId: batchId,
        quantitySold: qty,
        salePriceTotal: price,
        verificationTier: _selectedTier,
        buyerDetails: _buyerDetailsController.text.trim().isNotEmpty
            ? _buyerDetailsController.text.trim()
            : null,
      );
      if (!mounted) return;
      setState(() {
        _saleResult = res;
        _loadingSale = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saleError = e.toString().replaceFirst("Exception: ", "");
        _loadingSale = false;
      });
    }
  }

  Future<void> _fetchLedger() async {
    setState(() {
      _loadingLedger = true;
      _ledgerError = null;
    });

    try {
      final res = await _blockchainService.getLedgerBlocks(limit: 30);
      if (!mounted) return;
      setState(() {
        _ledgerBlocks = res;
        _loadingLedger = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ledgerError = e.toString().replaceFirst("Exception: ", "");
        _loadingLedger = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.get(
            "Blockchain Anti-Fraud Registry",
            "ബ്ലോക്ക്ചെയിൻ വ്യാജവിരുദ്ധ രജിസ്ട്രി",
            "ब्लॉकचेन धोखाधड़ी रोधी रजिस्ट्री",
            "பிளாக்செயின் மோசடி தடுப்பு பதிவேடு",
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: "Fertilizer MRP"),
            Tab(icon: Icon(Icons.verified), text: "Verify Produce"),
            Tab(icon: Icon(Icons.receipt_long), text: "Record Sale"),
            Tab(icon: Icon(Icons.account_tree), text: "Public Ledger"),
          ],
          onTap: (index) {
            if (index == 3 && _ledgerBlocks.isEmpty) {
              _fetchLedger();
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFertilizerTab(),
          _buildProduceTab(),
          _buildRecordSaleTab(),
          _buildLedgerTab(),
        ],
      ),
    );
  }

  Widget _buildFertilizerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Official MRP & Dealer Price Check",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Scan fertilizer QR code or enter batch number to verify statutory price and prevent black market hoarding.",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _fertBatchController,
                    decoration: const InputDecoration(
                      labelText: "Fertilizer Batch Number",
                      hintText: "e.g. IFFCO-TEST-2026-01",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dealerPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Dealer Asking Price (INR, Optional)",
                      hintText: "e.g. 250",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _loadingFert ? null : _verifyFertilizer,
                      icon: _loadingFert
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.security),
                      label: const Text("Verify with Blockchain"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_fertError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_fertError!, style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
          if (_fertResult != null) ...[
            const SizedBox(height: 16),
            _buildFertResultCard(_fertResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildFertResultCard(Map<String, dynamic> res) {
    final bool authentic = res["authentic"] == true;
    final bool overcharging = res["overcharging_detected"] == true;
    final double? officialMrp = (res["official_mrp_inr"] as num?)?.toDouble();
    final double? askingPrice = (res["dealer_asking_price"] as num?)?.toDouble();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  authentic ? Icons.check_circle : Icons.warning,
                  color: authentic ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  authentic ? "GENUINE REGISTERED BATCH" : "UNVERIFIED BATCH",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: authentic ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow("Product Name", "${res["fertilizer_name"] ?? 'Unknown'}"),
            _infoRow("Manufacturer", "${res["manufacturer"] ?? 'Unknown'}"),
            _infoRow("Batch Number", "${res["batch_number"] ?? ''}"),
            _infoRow(
              "Statutory MRP",
              officialMrp != null ? "INR ${officialMrp.toStringAsFixed(2)}" : "N/A",
              isHighlight: true,
            ),
            if (askingPrice != null)
              _infoRow("Dealer Price", "INR ${askingPrice.toStringAsFixed(2)}"),
            if (overcharging) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PRICE VIOLATION DETECTED",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Dealer is asking INR ${askingPrice?.toStringAsFixed(2)}, which exceeds statutory MRP by INR ${((askingPrice ?? 0) - (officialMrp ?? 0)).toStringAsFixed(2)}. Report immediately to Department of Agriculture Hotline: 1800-180-1551.",
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            _infoRow("Cryptographic Hash", "${res["merkle_hash"] ?? ''}", isSmall: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProduceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Produce Traceability & Stock Provenance",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Verify farm origin, harvest authenticity, and tamper-proof blockchain status for direct produce purchases.",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _produceBatchController,
                    decoration: const InputDecoration(
                      labelText: "Produce Batch ID or Merkle Hash",
                      hintText: "Enter batch code or scan consumer QR",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code_scanner),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _loadingProduce ? null : _verifyProduce,
                      icon: _loadingProduce
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_user),
                      label: const Text("Verify Provenance"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_produceError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_produceError!, style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ],
          if (_produceResult != null) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _produceResult!["verified"] == true
                              ? Icons.verified
                              : Icons.help_outline,
                          color: _produceResult!["verified"] == true
                              ? Colors.green
                              : Colors.orange,
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _produceResult!["verified"] == true
                              ? "AUTHENTIC REGISTERED PRODUCE"
                              : "STATUS UNCONFIRMED",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _produceResult!["verified"] == true
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _infoRow("Batch ID", "${_produceResult!["produce_batch_id"] ?? ''}"),
                    _infoRow("Produce Type", "${_produceResult!["produce_type"] ?? ''}"),
                    _infoRow(
                      "Quantity",
                      "${_produceResult!["quantity"] ?? ''} ${_produceResult!["quantity_unit"] ?? 'kg'}",
                    ),
                    _infoRow("Farmer Profile ID", "${_produceResult!["farmer_profile_id"] ?? ''}"),
                    _infoRow("Registered Date", "${_produceResult!["created_at"] ?? ''}"),
                    _infoRow("Merkle Proof", "${_produceResult!["merkle_hash"] ?? ''}", isSmall: true),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordSaleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Two-Tier Sold Product Recorder",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "Record produce sales onto the blockchain ledger tagged as either PLATFORM_VERIFIED or SELF_REPORTED.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _saleBatchIdController,
                decoration: const InputDecoration(
                  labelText: "Produce Batch ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _saleQtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Quantity Sold",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _salePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Total Sale Price (INR)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _buyerDetailsController,
                decoration: const InputDecoration(
                  labelText: "Buyer Details (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Verification Tier:", style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text("PLATFORM_VERIFIED (Payment processed through platform)"),
                value: "PLATFORM_VERIFIED",
                groupValue: _selectedTier,
                onChanged: (v) => setState(() => _selectedTier = v!),
              ),
              RadioListTile<String>(
                title: const Text("SELF_REPORTED (Direct cash or external offline sale)"),
                value: "SELF_REPORTED",
                groupValue: _selectedTier,
                onChanged: (v) => setState(() => _selectedTier = v!),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _loadingSale ? null : _recordSale,
                  icon: _loadingSale
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: const Text("Record Sale on Ledger"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (_saleError != null) ...[
                const SizedBox(height: 12),
                Text(_saleError!, style: const TextStyle(color: Colors.red)),
              ],
              if (_saleResult != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Sale recorded successfully. Ledger block created with tier ${_saleResult!["verification_tier"]}.",
                    style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLedgerTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Immutable Audit Trail",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchLedger,
              ),
            ],
          ),
        ),
        if (_loadingLedger)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_ledgerError != null)
          Expanded(child: Center(child: Text(_ledgerError!)))
        else if (_ledgerBlocks.isEmpty)
          const Expanded(child: Center(child: Text("No ledger blocks found.")))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _ledgerBlocks.length,
              itemBuilder: (context, index) {
                final b = _ledgerBlocks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Text("${b["block_index"] ?? index}"),
                    ),
                    title: Text(
                      "${b["transaction_type"] ?? 'TRANSACTION'}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hash: ${b["block_hash"] ?? ''}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontFamily: "monospace"),
                        ),
                        Text(
                          "Time: ${b["timestamp"] ?? ''}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlight = false, bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: isSmall ? 12 : 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.green.shade800 : Colors.black87,
                fontSize: isSmall ? 12 : (isHighlight ? 16 : 14),
                fontFamily: isSmall ? "monospace" : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
