import 'package:flutter/material.dart';
import 'package:myapp/generated/i18n/app_localizations.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:myapp/widgets/button/primary_button.dart';
import 'package:myapp/src/config/constants/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    final onboardingData = AppConstants.getOnboardingData(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  UserPrefs.I.setHasSeenOnboarding(true);
                  //context.go(AppRouteNames.gettingStarted.path);
                  AppCoordinator.showGettingStartedScreen();
                },
                child: Text(
                  AppLocalizations.of(context)!.common_buttonSkip,
                  style: const TextStyle(
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  title: onboardingData[index]['title'],
                  subtitle: onboardingData[index]['subtitle'],
                  icon: onboardingData[index]['icon'],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 30),
                  XPrimaryButton(
                    text: _currentPage == onboardingData.length - 1
                        ? AppLocalizations.of(context)!.common_buttonDiscover
                        : AppLocalizations.of(context)!.common_buttonContinue,
                    onPressed: () {
                      if (_currentPage == onboardingData.length - 1) {
                        UserPrefs.I.setHasSeenOnboarding(true);
                        AppCoordinator.showGettingStartedScreen();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color:
            _currentPage == index ? const Color(0xFF6C63FF) : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const OnboardingContent({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 100,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
