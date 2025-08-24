import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/pos/controllers/pos_controller.dart';

class CheckoutDialog extends StatelessWidget {
  final PosController controller;

  const CheckoutDialog({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9 > 500 
            ? 500 
            : MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: Colors.brown[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Checkout',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Order Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Items List
                  Obx(() => Column(
                    children: controller.cartItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.quantity}x ${item.productName}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              'Rp ${item.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )),
                  const Divider(),
                  // Totals
                  Obx(() => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:'),
                          Text(
                            'Rp ${controller.totalAmount.value.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax (10%):'),
                          Text(
                            'Rp ${controller.taxAmount.value.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rp ${controller.finalAmount.value.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Payment Method Selection
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: [
                // Cash Payment
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.money, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Cash'),
                    ],
                  ),
                  value: 'cash',
                  groupValue: controller.paymentMethod.value,
                  onChanged: (value) => controller.setPaymentMethod(value!),
                  activeColor: Colors.brown[700],
                ),
                // Card Payment
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Card'),
                    ],
                  ),
                  value: 'card',
                  groupValue: controller.paymentMethod.value,
                  onChanged: (value) => controller.setPaymentMethod(value!),
                  activeColor: Colors.brown[700],
                ),
                // Digital Wallet
                RadioListTile<String>(
                  title: const Row(
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Digital Wallet'),
                    ],
                  ),
                  value: 'digital_wallet',
                  groupValue: controller.paymentMethod.value,
                  onChanged: (value) => controller.setPaymentMethod(value!),
                  activeColor: Colors.brown[700],
                ),
              ],
            )),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            await controller.processTransaction();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Process Payment',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}