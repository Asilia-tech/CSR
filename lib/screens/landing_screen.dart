// import 'package:flutter/material.dart';
// import 'package:sterlite_csr/constants.dart';

// class LandingPage extends StatelessWidget {
//   const LandingPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Stack(
//         children: [
//           // Background shapes
//           Positioned(
//             top: -100,
//             right: -100,
//             child: Container(
//               width: 300,
//               height: 300,
//               decoration: BoxDecoration(
//                 color: Constants.secondaryColor.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -150,
//             left: -150,
//             child: Container(
//               width: 350,
//               height: 350,
//               decoration: BoxDecoration(
//                 color: Constants.primaryColor.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),

//           // Main content container
//           Column(
//             children: [
//               // Top navigation bar
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Logo
//                     Align(
//                         alignment: Alignment.topCenter,
//                         child:
//                             Image.asset('assets/images/logo.png', height: 60)),

//                     // Social links and login button for second section
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.facebook,
//                               color: Colors.blueGrey),
//                           onPressed: () {},
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.wechat_sharp,
//                               color: Colors.blueGrey),
//                           onPressed: () {},
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.mail, color: Colors.blueGrey),
//                           onPressed: () {},
//                         ),
//                         const SizedBox(width: 8),
//                         ElevatedButton(
//                           onPressed: () {
//                             Navigator.pushNamed(context, '/login');
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Constants.primaryColor,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(50),
//                             ),
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 24, vertical: 12),
//                           ),
//                           child: const Text(
//                             'Login',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       _buildTeach2030Section(context),
//                       _buildProgramKeyPillarsSection(context),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // First section with Teach 2030 content
//   Widget _buildTeach2030Section(BuildContext context) {
//     return Column(
//       children: [
//         const SizedBox(height: 60),
//         // Heading
//         RichText(
//           textAlign: TextAlign.center,
//           text: TextSpan(
//             children: [
//               TextSpan(
//                 text: 'Masoom Education\n',
//                 style: TextStyle(
//                   color: Constants.secondaryColor,
//                   fontSize: 48,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextSpan(
//                 text: 'Teacher Portal',
//                 style: TextStyle(
//                   color: Constants.primaryColor,
//                   fontSize: 48,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 24),

//         // Description
//         Container(
//           width: MediaQuery.of(context).size.width * 0.8,
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: const Text(
//             'Our vision is that every school dropout has the right to complete 10th and 12th grade with skilling & livelihood opportunities to shape a better future for themselves and the world around them.',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Color(0xFF475569),
//               fontSize: 18,
//               height: 1.5,
//             ),
//           ),
//         ),
//         const SizedBox(height: 40),
//         // Buttons
//         ElevatedButton(
//           onPressed: () {
//             Navigator.pushNamed(context, '/login');
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Constants.secondaryColor,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(50),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//           ),
//           child: const Text(
//             'Start Your Journey',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         const SizedBox(height: 24),
//         Container(
//           height: 1,
//           color: Colors.grey.shade200,
//           margin: const EdgeInsets.symmetric(horizontal: 24),
//         ),
//         const SizedBox(height: 24),
//       ],
//     );
//   }

//   // Second section with Program Key Pillars
//   Widget _buildProgramKeyPillarsSection(BuildContext context) {
//     return Column(
//       children: [
//         // Title Section
//         const Text(
//           'Our Programs',
//           style: TextStyle(
//             fontSize: 32,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1E293B),
//           ),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 16),
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24),
//           child: Text(
//             'Our work is driven through four key verticals',
//             style: TextStyle(
//               fontSize: 16,
//               color: Color(0xFF64748B),
//               height: 1.5,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ),
//         const SizedBox(height: 16),
//         _buildKeyPillarsCards(context),
//         const SizedBox(height: 60),
//       ],
//     );
//   }

//   Widget _buildKeyPillarsCards(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           if (constraints.maxWidth > 800) {
//             return Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: _buildPillarCard(
//                     iconBackgroundColor: Colors.blue,
//                     icon: Icons.school,
//                     title: 'Night School Transformation Program',
//                     description:
//                         'The Night School Transformation Program (NSTP) is a highly successful flagship initiative aimed at revitalizing night schools across Maharashtra. It is currently active in 100  night schools, impacting over 75000 students. The NSTP focuses on enhancing the educational experience for students who work during the day and attend school at night. ',
//                     cardBackgroundColor: const Color(0xFFF1F7FE),
//                   ),
//                 ),
//                 const SizedBox(width: 24),
//                 Expanded(
//                   child: _buildPillarCard(
//                     iconBackgroundColor: Constants.redColor,
//                     icon: Icons.schedule_outlined,
//                     title: 'Evening Learning Center',
//                     description:
//                         'The Evening Learning Center (ELC) program was launched in 2020 with the goal of providing an opportunity for out-of-school students, dropouts, and individuals who failed their Grade 10 exams (aged 14 and above) to complete their education in regions where night schools are not available. The program helps these students prepare for their Grade 10 exams, opening pathways to better job opportunities and further education.',
//                     cardBackgroundColor: Color.fromARGB(255, 254, 244, 241),
//                   ),
//                 ),
//                 const SizedBox(width: 24),
//                 Expanded(
//                   child: _buildPillarCard(
//                     iconBackgroundColor: Constants.greenColor,
//                     icon: Icons.bus_alert,
//                     title: 'Teach on Wheels',
//                     description:
//                         'The Tech on Wheels (TOW) initiative aims to bridge the digital divide by providing underserved communities with access to technological education and resources through mobile units equipped with computers, internet access, and educational software.The goal is to empower students with digital literacy, soft skills, and technical knowledge, enabling them to pursue higher education and better career opportunities. ',
//                     cardBackgroundColor: const Color(0xFFF0FBF8),
//                   ),
//                 ),
//                 const SizedBox(width: 24),
//                 Expanded(
//                   child: _buildPillarCard(
//                     iconBackgroundColor: Constants.ternaryColor,
//                     icon: Icons.line_axis,
//                     title: 'Career Cell',
//                     description:
//                         'The initiative focuses on helping students explore diverse career paths, develop technical and entrepreneurial skills, and improve their overall standard of living. The Career Cell offers scholarships, career counseling, and support for both short-term vocational training and long-term professional education, aiming to empower students to break free from the cycle of poverty and secure better opportunities in the organized sector. ',
//                     cardBackgroundColor: const Color(0xFFF5F1FD),
//                   ),
//                 ),
//               ],
//             );
//           } else {
//             return Column(
//               children: [
//                 _buildPillarCard(
//                   iconBackgroundColor: Colors.blue,
//                   icon: Icons.school,
//                   title: 'Night School Transformation Program',
//                   description:
//                       'The Night School Transformation Program (NSTP) is a highly successful flagship initiative aimed at revitalizing night schools across Maharashtra.',
//                   cardBackgroundColor: const Color(0xFFF1F7FE),
//                 ),
//                 const SizedBox(height: 24),
//                 _buildPillarCard(
//                   iconBackgroundColor: Constants.redColor,
//                   icon: Icons.schedule_outlined,
//                   title: 'Evening Learning Center',
//                   description:
//                       'The Evening Learning Center (ELC) program was launched in 2020 with the goal of providing an opportunity for out-of-school students, dropouts, and individuals who failed their Grade 10 exams (aged 14 and above) to complete their education in regions where night schools are not available.',
//                   cardBackgroundColor: Color.fromARGB(255, 254, 244, 241),
//                 ),
//                 const SizedBox(height: 24),
//                 _buildPillarCard(
//                   iconBackgroundColor: Constants.greenColor,
//                   icon: Icons.bus_alert,
//                   title: 'Teach on Wheels',
//                   description:
//                       'The Tech on Wheels (TOW) initiative aims to bridge the digital divide by providing underserved communities with access to technological education and resources through mobile units equipped with computers, internet access, and educational software.',
//                   cardBackgroundColor: const Color(0xFFF5F1FD),
//                 ),
//                 const SizedBox(height: 24),
//                 _buildPillarCard(
//                   iconBackgroundColor: Constants.ternaryColor,
//                   icon: Icons.line_axis,
//                   title: 'Career Cell',
//                   description:
//                       'The initiative focuses on helping students explore diverse career paths, develop technical and entrepreneurial skills, and improve their overall standard of living.',
//                   cardBackgroundColor: const Color(0xFFF5F1FD),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildPillarCard({
//     required Color iconBackgroundColor,
//     required IconData icon,
//     required String title,
//     required String description,
//     required Color cardBackgroundColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: cardBackgroundColor,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Icon
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: iconBackgroundColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: 24,
//             ),
//           ),
//           const SizedBox(height: 24),

//           // Title
//           Text(
//             title,
//             textAlign: TextAlign.left,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF1E293B),
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Description
//           Text(
//             description,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Color(0xFF64748B),
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isMobileMenuOpen = false;
  double _scrollProgress = 0.0;

  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  void _onScroll() {
    setState(() {
      _scrollProgress = _scrollController.hasClients
          ? (_scrollController.offset /
              _scrollController.position.maxScrollExtent)
          : 0.0;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              _buildAppBar(),
              // Hero Section
              SliverToBoxAdapter(child: _buildHeroSection()),
              // Features Section
              SliverToBoxAdapter(child: _buildFeaturesSection()),
              // Footer
              SliverToBoxAdapter(child: _buildFooter()),
            ],
          ),

          // Progress Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _scrollProgress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2563EB),
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true,
      elevation: 0,
      toolbarHeight: 70,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo
                Row(
                  children: [
                    // Container(
                    //   width: 48,
                    //   height: 48,
                    //   decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //     image: AssetImage('assets/images/logo.png'),
                    //   )),
                    // ),
                    const SizedBox(width: 12),
                    Text(
                      'CSR Monitor',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ],
                ),

                // Desktop Navigation
                if (MediaQuery.of(context).size.width > 768)
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                    ],
                  )
                else
                  // Mobile Navigation
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isMobileMenuOpen = !_isMobileMenuOpen;
                          });
                        },
                        icon: const Icon(Icons.menu),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
        child: Column(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.rocket_launch_rounded,
                    size: 16,
                    color: Color(0xFF1D4ED8),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Next-Generation Monitoring Platform',
                    style: TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Title
            Text(
              'Monitor Your CSR Operations\nin Real-Time',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 768 ? 56 : 36,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111827),
                height: 1.2,
              ),
            ),

            const SizedBox(height: 24),

            // Description
            const Text(
              'Comprehensive monitoring and analytics for your Corporate Social\nResponsibility initiatives. Track impact, measure outcomes, and\ndrive meaningful change.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
            ),

            const SizedBox(height: 64),

            // Dashboard Preview
            Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  // Window Controls
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildWindowButton(Colors.red),
                        const SizedBox(width: 8),
                        _buildWindowButton(Colors.yellow),
                        const SizedBox(width: 8),
                        _buildWindowButton(Colors.green),
                      ],
                    ),
                  ),

                  // Dashboard Content
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildDashboardCard(
                              Icons.bar_chart_rounded,
                              'Analytics',
                              'Real-time insights and metrics',
                              const Color(0xFF2563EB),
                              constraints.maxWidth > 768
                                  ? 280
                                  : constraints.maxWidth - 64,
                            ),
                            _buildDashboardCard(
                              Icons.lock_rounded,
                              'Secure',
                              'Enterprise-grade security',
                              const Color(0xFF4F46E5),
                              constraints.maxWidth > 768
                                  ? 280
                                  : constraints.maxWidth - 64,
                            ),
                            _buildDashboardCard(
                              Icons.check_circle_rounded,
                              'Compliant',
                              'Industry standards certified',
                              const Color(0xFF059669),
                              constraints.maxWidth > 768
                                  ? 280
                                  : constraints.maxWidth - 64,
                            ),
                          ],
                        );
                      },
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

  Widget _buildWindowButton(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDashboardCard(
    IconData icon,
    String title,
    String description,
    Color color,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      _FeatureData(
        icon: Icons.dashboard_rounded,
        title: 'Real-Time Dashboard',
        description:
            'Monitor all your CSR metrics in one unified, intuitive dashboard with live updates.',
        color: const Color(0xFF2563EB),
      ),
      _FeatureData(
        icon: Icons.analytics_rounded,
        title: 'Advanced Analytics',
        description:
            'Gain deep insights with powerful analytics and customizable reporting tools.',
        color: const Color(0xFF4F46E5),
      ),
      _FeatureData(
        icon: Icons.history_rounded,
        title: 'Activity Tracking',
        description:
            'Track every action and event with comprehensive audit logs and history.',
        color: const Color(0xFF7C3AED),
      ),
      _FeatureData(
        icon: Icons.check_circle_outline_rounded,
        title: 'Compliance Monitoring',
        description:
            'Ensure adherence to CSR guidelines and regulatory requirements automatically.',
        color: const Color(0xFF059669),
      ),
      _FeatureData(
        icon: Icons.lock_outline_rounded,
        title: 'Secure Access',
        description:
            'Role-based access control with enterprise-grade security protocols.',
        color: const Color(0xFFDC2626),
      ),
      _FeatureData(
        icon: Icons.rocket_launch_rounded,
        title: 'Quick Integration',
        description:
            'Easy setup with existing systems through our robust API and webhooks.',
        color: const Color(0xFFEA580C),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
      color: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          const Text(
            'Powerful Features',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Everything you need to manage and monitor your CSR initiatives',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 64),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1024
                  ? 3
                  : constraints.maxWidth > 640
                      ? 2
                      : 1;
              return Wrap(
                spacing: 32,
                runSpacing: 32,
                alignment: WrapAlignment.center,
                children: features.map((feature) {
                  final width = constraints.maxWidth > 1024
                      ? (constraints.maxWidth - 64) / 3 - 32
                      : constraints.maxWidth > 640
                          ? (constraints.maxWidth - 32) / 2 - 32
                          : constraints.maxWidth - 32;
                  return _buildFeatureCard(feature, width);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(_FeatureData feature, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: feature.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              feature.icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            feature.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            feature.description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
      ),
      child: const Center(
        child: Text(
          '© 2024 CSR Monitor. All rights reserved.',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _StatData {
  final String value;
  final String label;

  _StatData(this.value, this.label);
}
