import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';

class ChannelScreen extends StatelessWidget {
  const ChannelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.channel),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Channel Banner
            Container(
              height: 120,
              color: AppColors.primary,
            ),
            // Channel Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.surface,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KVZR Channel',
                          style: TextStyle(
                            color: AppColors.onBackground,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1.2M subscribers',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Subscribe Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomButton(
                text: AppStrings.subscribe,
                onPressed: () {},
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 24),
            // Tabs
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Home'),
                      Tab(text: 'Videos'),
                      Tab(text: 'About'),
                    ],
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.onSurface,
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildHomeTab(),
                        _buildVideosTab(),
                        _buildAboutTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return const Center(
      child: Text(
        'Featured Content',
        style: TextStyle(color: AppColors.onSurface),
      ),
    );
  }

  Widget _buildVideosTab() {
    return const Center(
      child: Text(
        'All Videos',
        style: TextStyle(color: AppColors.onSurface),
      ),
    );
  }

  Widget _buildAboutTab() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Welcome to KVZR Channel. Powered by Leonardo App.',
        style: TextStyle(color: AppColors.onSurface),
      ),
    );
  }
}
