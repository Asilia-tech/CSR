import 'package:flutter/material.dart';
import 'package:sterlite_csr/constants.dart';
import 'dart:ui';
import 'package:sterlite_csr/theme/theme_controller.dart';

class ReportUtils {
  static Widget buildAdminCount(
      String countName, IconData? countIcon, String countTotal) {
    return SizedBox(
      height: 100,
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Align(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(countIcon, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      countName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  countTotal,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildMetricCard(
      BuildContext context,
      String title,
      String value,
      // String change,
      Color accentColor,
      IconData icon,
      Color iconBgColor,
      ThemeController themeController) {
    return Container(
      height: MediaQuery.of(context).size.width < 700 ? 120 : 140,
      width: MediaQuery.of(context).size.width < 700 ? 160 : 225,
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? Constants.canvasColor
            : Constants.whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          top: BorderSide(color: accentColor, width: 3),
          left: BorderSide(color: accentColor, width: 1),
          right: BorderSide(color: accentColor, width: 1),
          bottom: BorderSide(color: accentColor, width: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.width < 700 ? 0 : 12),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 700 ? 24 : 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              // Text(
              //   change,
              //   style: TextStyle(
              //     color: accentColor,
              //     fontSize: 14,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 3),
          // const Text(
          //   'Compared to last month',
          //   style: TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
          // ),
        ],
      ),
    );
  }

  static Widget buildStatusCard(
      BuildContext context,
      String title,
      String value,
      double progress,
      Color progressColor,
      IconData icon,
      ThemeController themeController) {
    return Container(
      width: MediaQuery.of(context).size.width < 700 ? 160 : 225,
      decoration: BoxDecoration(
        color: themeController.isDarkMode.value
            ? Constants.canvasColor
            : Constants.whiteColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: themeController.isDarkMode.value
                ? Constants.canvasColor
                : Constants.greyColor,
            width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: progressColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                icon,
                color: progressColor,
                size: MediaQuery.of(context).size.width < 700 ? 30 : 38,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: !themeController.isDarkMode.value
                  ? Constants.canvasColor.withOpacity(0.1)
                  : Constants.whiteColor.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildChartCardHeader(String title, Widget chartWidget) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Constants.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: chartWidget,
          )
        ],
      ),
    );
  }

  static Widget buildModernCard({
    required String title,
    required String count,
    required Icon icon,
    required Color iconBackgroundColor,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 80,
          minWidth: 120,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }

            bool useVerticalLayout = constraints.maxWidth < 160;

            if (useVerticalLayout) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon.icon,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    count,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: constraints.maxWidth > 200 ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          count,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: constraints.maxWidth > 200 ? 18 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  static Widget buildPaginationControls({
    required int currentPage,
    required int totalRows,
    required int rowsPerPage,
    required ValueChanged<int> onPageChanged,
  }) {
    final int totalPages = (totalRows / rowsPerPage).ceil();
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Page ${currentPage + 1} of $totalPages'),
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: currentPage == 0 ? null : () => onPageChanged(0),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed:
              currentPage == 0 ? null : () => onPageChanged(currentPage - 1),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage >= totalPages - 1
              ? null
              : () => onPageChanged(currentPage + 1),
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: currentPage >= totalPages - 1
              ? null
              : () => onPageChanged(totalPages - 1),
        ),
      ],
    );
  }

  static Widget buildStyledCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0369A1).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  static Widget buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    const Color scaffoldBackgroundColor = Color(0xFFF8FAFC);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: selectedValue,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF1E232C))),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey.shade600),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  const BorderSide(color: Color(0xFF0369A1), width: 1.5),
            ),
          ),
        ),
        Positioned(
          top: -8,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            color: scaffoldBackgroundColor,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // static buildCard(String title, Widget icon, Function()? onTap,
  //     Color color, Color color1, double width) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         gradient: LinearGradient(
  //           begin: Alignment.topRight,
  //           end: Alignment.bottomLeft,
  //           colors: [
  //             color,
  //             color1,
  //           ],
  //         ),
  //         border: Border.all(color: Constants.primaryColor),
  //       ),
  //       width: width,
  //       child: Column(
  //         children: [
  //           Container(
  //             child: icon,
  //             padding: const EdgeInsets.all(5),
  //           ),
  //           Container(
  //             child: Text(
  //               title,
  //               textAlign: TextAlign.center,
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             padding: const EdgeInsets.all(5),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // static buildCard(
  //     BuildContext context, String label, Function()? onTap, String imgPath) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Card(
  //       color: Colors.lightBlue.shade50,
  //       elevation: 5,
  //       child: SizedBox(
  //         width: 20.h,
  //         height: 20.h,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             SizedBox(
  //                 width: 10.h,
  //                 height: 10.h,
  //                 child: Image.asset(imgPath, fit: BoxFit.fill)),
  //             const SizedBox(height: 5),
  //             FittedBox(
  //                 child: Text(
  //               label,
  //               style: const TextStyle(
  //                   color: Colors.blue, fontWeight: FontWeight.bold),
  //             )),
  //             const SizedBox(height: 5),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // static buildCard(String title, Widget icon, Function()? onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         color: Colors.white,
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black,
  //             spreadRadius: 1,
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         children: [
  //           Container(
  //             child: icon,
  //             padding: const EdgeInsets.all(12),
  //           ),
  //           Container(
  //             decoration: const BoxDecoration(
  //                 color: Colors.teal,
  //                 borderRadius: BorderRadius.only(
  //                     bottomRight: Radius.circular(12),
  //                     bottomLeft: Radius.circular(12))),
  //             child: Text(
  //               title,
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             padding: const EdgeInsets.all(12),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // static buildCard(String title, Widget icon, Function()? onTap, Color color,
  //     Color color1, double width) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         gradient: LinearGradient(
  //           begin: Alignment.topRight,
  //           end: Alignment.bottomLeft,
  //           colors: [
  //             color,
  //             color1,
  //           ],
  //         ),
  //         border: Border.all(color: Colors.transparent),
  //       ),
  //       width: width,
  //       child: Column(
  //         children: [
  //           Container(
  //             child: icon,
  //             padding: const EdgeInsets.all(5),
  //           ),
  //           Container(
  //             child: Text(
  //               title,
  //               textAlign: TextAlign.center,
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             padding: const EdgeInsets.all(5),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // static buildCard(
  //     String title, Widget icon, Function()? onTap, Color color) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 175,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         color: Colors.white,
  //         boxShadow: const [
  //           BoxShadow(color: Colors.black, spreadRadius: 1),
  //         ],
  //       ),
  //       child: Column(
  //         children: [
  //           Padding(padding: const EdgeInsets.all(12), child: icon),
  //           Container(
  //             width: 175,
  //             decoration: BoxDecoration(
  //               color: color,
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Center(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(12),
  //                 child: Text(
  //                   title,
  //                   style: const TextStyle(fontSize: 13, color: Colors.white),
  //                 ),
  //               ),
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // static buildCard(String title, Widget icon, Function()? onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         color: Colors.white,
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black,
  //             spreadRadius: 1,
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         children: [
  //           Container(
  //             child: icon,
  //             padding: const EdgeInsets.all(12),
  //           ),
  //           Container(
  //             decoration: const BoxDecoration(
  //                 color: Colors.teal,
  //                 borderRadius: BorderRadius.only(
  //                     bottomRight: Radius.circular(12),
  //                     bottomLeft: Radius.circular(12))),
  //             child: Text(
  //               title,
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             padding: const EdgeInsets.all(12),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
