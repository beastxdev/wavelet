import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'services/api_service.dart';
import 'services/audio_player_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WaveletApp());
}

class WaveletApp extends StatelessWidget {
  const WaveletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiConfig()),
        Provider(create: (context) => ApiService(context.read<ApiConfig>())),
        ChangeNotifierProvider(create: (_) => AudioPlayerService()),
      ],
      child: MaterialApp(
        title: 'Wavelet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF080B10),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1ED760),
            brightness: Brightness.dark,
            primary: const Color(0xFF1ED760),
            secondary: const Color(0xFF39A7FF),
            surface: const Color(0xFF111820),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF080B10),
            centerTitle: false,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF111820),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF111820),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const LoadingScreen(next: HomeScreen()),
      ),
    );
  }
}
