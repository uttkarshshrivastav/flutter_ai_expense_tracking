import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Works now!
import 'package:upi_parser_ai/upi_parser_ai.dart';

import 'features/transactions/bloc/collector_bloc.dart';
import 'features/transactions/bloc/transaction_crud_bloc.dart';
import 'features/transactions/bloc/transaction_parser_bloc.dart';
import 'features/transactions/repository/sms_repository.dart';
import 'core/database/database_helper.dart';
import 'core/utils/mock_injector.dart';
import 'features/review/ui/review_screen.dart';
import 'features/analytics/ui/analytics_dashboard.dart';

const bool demoMode = true; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load the environment variables
  await dotenv.load(fileName: ".env");

  final databaseHelper = DatabaseHelper();
  await databaseHelper.database;

  if (demoMode) {
    await MockInjector(databaseHelper: databaseHelper).ensureDemoData();
  }

  runApp(UpiAnalyzerApp(databaseHelper: databaseHelper));
}

class UpiAnalyzerApp extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  const UpiAnalyzerApp({Key? key, required this.databaseHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely fetch the API key. Defaults to empty string if missing.
    final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

    return MaterialApp(
      title: 'UPI Analyzer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => CollectorBloc(
              smsRepository: SmsRepository(),
            )..add(CheckPermissions()),
          ),
          BlocProvider(
            create: (context) => TransactionParserBloc(
              databaseHelper: databaseHelper,
              // Make sure "apiKey:" is written out!
              groqClient: GroqClient(apiKey: dotenv.env['GROQ_API_KEY'] ?? ''), 
            )..add(StartParsing()),
          ),
          BlocProvider(
            create: (context) => TransactionCrudBloc(
              databaseHelper: databaseHelper,
            )..add(LoadTransactions()),
          ),
        ],
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('UPI Analyzer', style: TextStyle(color: Colors.black87)),
              backgroundColor: Colors.white,
              elevation: 0,
              bottom: const TabBar(
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black87,
                tabs: [
                  Tab(text: 'Review'),
                  Tab(text: 'Analytics'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                const ReviewScreen(), // <-- Removed the parameter!
                const AnalyticsDashboard(),
                ],
            ),
          ),
        ),
      ),
    );
  }
}