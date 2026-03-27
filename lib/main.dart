import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'models/inspection.dart';
import 'services/inspection_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  // Ensure the adapter is registered for your database
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(InspectionAdapter());
  }

  await Hive.openBox<Inspection>('inspections_box');
  runApp(const ApisIntelApp());
}

class ApisIntelApp extends StatelessWidget {
  const ApisIntelApp({super.key});
  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.amber),
              useMaterial3: true
          ),
          home: const HomeScreen(),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InspectionEngine _engine = InspectionEngine();
  String _lastWords = "Ready to inspect...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ApisIntel Dashboard'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // THE VISUAL FEEDBACK BOX
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade700, width: 2),
              ),
              child: Text(
                _lastWords,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () => _engine.startInspection(
                "Parker County",
                onResult: (text) => setState(() => _lastWords = text),
              ),
              icon: const Icon(Icons.mic, size: 32),
              label: const Text('START INSPECTION', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}