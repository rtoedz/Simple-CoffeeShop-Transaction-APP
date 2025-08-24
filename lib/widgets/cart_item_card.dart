import 'package:flutter/material.dart';
import '../core/models/transaction_model.dart';

class CartItemCard extends StatelessWidget {
  final TransactionItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name and Remove Button
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: onRemove,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Price per unit
            Text(
              'Rp ${item.price.toStringAsFixed(0)} per item',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            // Quantity Controls and Subtotal
            Row(
              children: [
                // Quantity Controls
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Decrease Button
                      InkWell(
                        onTap: () {
                          if (item.quantity > 1) {
                            onQuantityChanged(item.quantity - 1);
                          } else {
                            onRemove();
                          }
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Icon(
                            item.quantity > 1 ? Icons.remove : Icons.delete,
                            size: 18,
                            color: item.quantity > 1 ? Colors.brown[700] : Colors.red,
                          ),
                        ),
                      ),
                      // Quantity Display
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            vertical: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Increase Button
                      InkWell(
                        onTap: () => onQuantityChanged(item.quantity + 1),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: Colors.brown[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Subtotal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Rp ${item.subtotal.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}