import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/temperature_cards_widget.dart';
import '../services/temperature_service.dart';
import '../../info/widgets/info_tab_widget.dart';
import '../../../core/widgets/background_widget.dart';
import '../widgets/chart_wrapper_widget.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final tenMinutes = const Duration(seconds: 700);

  int _cIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _startPeriodicRefresh();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {});
        break;
      default:
        break;
    }
  }

  void _startPeriodicRefresh() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer(tenMinutes, () {
      // setState will call the build method again
      // and thus trigger a data refresh
      setState(() {});
    });
  }

  void _onTabTapped(int value) {
    setState(() {
      _cIndex = value;
    });
  }

  late final TemperatureService _temperatureService = TemperatureService();

  @override
  Widget build(BuildContext context) {
    _startPeriodicRefresh();

    const Color barColor = Color.fromRGBO(31, 123, 129, 0.7);

    final List<Widget> screens = [
      TemperatureCardsWidget(temperatureService: _temperatureService),
      ChartWrapperWidget(temperatureService: _temperatureService),
      const InfoTabWidget(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const BackgroundWidget(),
          SafeArea(
            child: IndexedStack(
              index: _cIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _cIndex,
        backgroundColor: barColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.thermostat),
            label: AppLocalizations.of(context)!.currentTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart),
            label: AppLocalizations.of(context)!.historyTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info),
            label: AppLocalizations.of(context)!.infoTab,
          ),
        ],
      ),
    );
  }
}
