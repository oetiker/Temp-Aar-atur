import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/temperature_cards_widget.dart';
import '../widgets/info_tab_widget.dart';
import '../widgets/background_widget.dart';
import '../widgets/chart_wrapper_widget.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final pageIndexNotifier = ValueNotifier<int>(0);
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
    pageController.animateToPage(
      value,
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
    );
  }

  late final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    _startPeriodicRefresh();
    
    const Color barColor = Color.fromRGBO(31, 123, 129, 0.7);
    
    final List<Widget> screens = [
      const TemperatureCardsWidget(),
      const ChartWrapperWidget(),
      const InfoTabWidget(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const BackgroundWidget(),
          PageView(
            controller: pageController,
            children: screens,
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