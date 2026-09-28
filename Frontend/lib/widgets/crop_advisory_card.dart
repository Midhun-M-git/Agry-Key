import 'package:flutter/material.dart';
import '../models/advisory.dart';

class CropAdvisoryCard extends StatelessWidget {
  final AdvisoryAlternative alternative;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onTap;

  const CropAdvisoryCard({
    super.key,
    required this.alternative,
    this.onPlayAudio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: alternative.rank == 1 ? Colors.amber : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Option #${alternative.rank}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: alternative.rank == 1 ? Colors.black87 : Colors.green.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        alternative.cropName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (onPlayAudio != null || alternative.spokenAudioUrl != null)
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, color: Colors.green),
                      onPressed: onPlayAudio,
                      tooltip: 'Listen to advice',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alternative.reasoningText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat('Yield', '${alternative.projectedYieldQuintal.toStringAsFixed(1)} Q'),
                    _buildStat('Cost', '₹${alternative.inputCostInr.toStringAsFixed(0)}'),
                    _buildStat(
                      'Net Profit',
                      '₹${alternative.netProfitInr.toStringAsFixed(0)}',
                      isHighlight: true,
                    ),
                    _buildStat('Risk', '${(alternative.riskScore * 100).toStringAsFixed(0)}%'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.green.shade800 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
