const String appName = 'Finance Analyzer';
const String appVersion = '1.0.0';

// Expense Categories
const List<String> expenseCategories = [
  'Rent',
  'Groceries',
  'Transport',
  'Entertainment',
  'Bills',
  'Shopping',
  'Other',
];

// Currency
const String defaultCurrency = '₹';

// Firestore Collections
const String usersCollection = 'users';
const String expensesCollection = 'expenses';
const String monthlySummaryCollection = 'monthly_summaries';
const String budgetGoalsCollection = 'budget_goals';

// Default Budget Limit
const double defaultBudgetLimit = 100000.0;

// Validation Rules
const int minPasswordLength = 6;
const double minExpenseAmount = 0.01;
const double maxExpenseAmount = 10000000.0;

// Date Formats
const String dateFormatPattern = 'dd MMM, yyyy';
const String monthFormatPattern = 'MMM yyyy';
const String monthKeyFormat = 'yyyy-MM';
