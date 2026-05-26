import 'package:flutter/material.dart';

class ExpenseCard extends StatelessWidget {
  final String category;
  final double amount;
  final DateTime date;
  final String? note;
  final VoidCallback? onTap;
  final VoidCallback? onDeletePressed;
  final Icon categoryIcon;

  const ExpenseCard({
    super.key,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
    this.onTap,
    this.onDeletePressed,
    required this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: categoryIcon,
        ),
        title: Text(
          category,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (note != null && note!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                note!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (onDeletePressed != null)
              SizedBox(
                height: 20,
                child: IconButton(
                  icon: const Icon(Icons.delete, size: 16),
                  onPressed: onDeletePressed,
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
