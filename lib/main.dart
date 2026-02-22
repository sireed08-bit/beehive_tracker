import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'engine/inspection_engine.dart';
import 'models/inspection.dart';
import 'services/gemini_advisor.dart';
import 'services/photo_service.dart';
import 'services/sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Hive.initFlutter();
  Hive.registerAdapter(InspectionAdapter());
  await Hive.openBox<Inspection>('inspections');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InspectionEngine()..initialize()),
        Provider(create: (_) => PhotoService()),
        Provider(create: (_) => SyncService()),
        Provider(create: (_) => GeminiAdvisor()),
      ],
      child: const ApiIntelApp(),
    ),
  );
}

class ApiIntelApp extends StatelessWidget {
  const ApiIntelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final baseLight = ThemeData(
          colorScheme: lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true,
        );

        final baseDark = ThemeData(
          colorScheme: darkDynamic ??
              ColorScheme.fromSeed(
                brightness: Brightness.dark,
                seedColor: Colors.amber,
              ),
          useMaterial3: true,
        );

        return MaterialApp(
          title: 'ApisIntel BI',
          theme: baseLight,
          darkTheme: baseDark,
          home: const InspectionHomePage(),
        );
      },
    );
  }
}

class InspectionHomePage extends StatelessWidget {
  const InspectionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<InspectionEngine>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ApisIntel BI - Voice Inspection'),
        actions: [
          IconButton(
            onPressed: () async {
              final sync = context.read<SyncService>();
              await sync.pushUnsynced(
                webhookUrl: dotenv.env['APPS_SCRIPT_URL'] ?? '',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync attempt completed.')),
                );
              }
            },
            icon: const Icon(Icons.cloud_upload),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Step: ${engine.step.name}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Listening: ${engine.isListening}'),
            const SizedBox(height: 8),
            Text('Transcript: ${engine.transcript}'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    final photoService = context.read<PhotoService>();
                    final link = await photoService.captureAndUploadJpeg(
                      driveFolderId: dotenv.env['GOOGLE_DRIVE_FOLDER_ID'] ?? '',
                    );
                    if (link != null) {
                      engine.current.photoWebViewLink = link;
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Picture'),
                ),
                OutlinedButton(
                  onPressed: () => engine.handleVoiceCommand('skip'),
                  child: const Text('Skip'),
                ),
                OutlinedButton(
                  onPressed: () => engine.handleVoiceCommand('next'),
                  child: const Text('Next'),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    final advisor = context.read<GeminiAdvisor>();
                    final advice = await advisor.generateAndSpeak(engine.current);
                    engine.current.aiSummary = advice;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(advice)),
                      );
                    }
                  },
                  child: const Text('Gemini Advice'),
                ),
                FilledButton(
                  onPressed: () async {
                    await Hive.box<Inspection>('inspections').add(engine.current);
                    await engine.handleVoiceCommand('done');
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
            const Divider(height: 32),
            Text('Current Hive: ${engine.current.hiveId}'),
            Text('Temperament: ${engine.current.temperament}'),
            Text('Mites: ${engine.current.miteCount}'),
            Text('Strength: ${engine.current.finalStrength}'),
          ],
        ),
      ),
    );
  }
}
