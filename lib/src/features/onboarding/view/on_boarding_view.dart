import 'package:flutter/material.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:myapp/widgets/button/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Dọn dẹp ảnh thông minh",
      "subtitle":
          "Tự động nhóm và xóa ảnh trùng lặp của bạn chỉ trong vài giây.",
      "icon": Icons.cleaning_services_outlined,
    },
    {
      "title": "Nâng cấp chất lượng AI",
      "subtitle":
          "Biến những bức ảnh cũ, vỡ nét trở nên sắc nét và sống động nhờ công nghệ AI",
      "icon": Icons.auto_fix_high,
    },
    {
      "title": "Kho ảnh bảo mật",
      "subtitle":
          "Lưu trữ những khoảnh khắc riêng tư an toàn tuyệt đối với mã hóa cấp cao và trình quản lý thông minh.",
      "icon": Icons.lock_person_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                child: const Text(
                  "Bỏ qua",
                  style: TextStyle(
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
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  title: _onboardingData[index]['title'],
                  subtitle: _onboardingData[index]['subtitle'],
                  icon: _onboardingData[index]['icon'],
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
                      _onboardingData.length,
                      (index) => buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 30),
                  XPrimaryButton(
                    text: _currentPage == _onboardingData.length - 1
                        ? "Khám phá ngay"
                        : "Tiếp tục",
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
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
