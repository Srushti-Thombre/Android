
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';

class ExpenseService {
  /// Create a new expense model (no persistence - handled by ExpenseProvider)
  ExpenseModel createExpense({
    required String userId,
    required String category,
    required double amount,
    required DateTime date,
    String note = '',
  }) {
    return ExpenseModel(
      id: const Uuid().v4(),
      userId: userId,
      category: category,
      amount: amount,
      date: date,
      note: note,
      createdAt: DateTime.now(),
    );
  }
}