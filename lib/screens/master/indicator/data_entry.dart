import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sterlite_csr/models/indicator_model.dart';
import 'package:sterlite_csr/models/location_model.dart';
import 'package:sterlite_csr/utilities/utils/search-dropdown_utils.dart';

class DataEntryScreen extends StatefulWidget {
  final bool isEdit;
  final IndicatorModel? indicator;

  DataEntryScreen({this.isEdit = false, this.indicator, super.key});

  @override
  _DataEntryScreenState createState() => _DataEntryScreenState();
}

class _DataEntryScreenState extends State<DataEntryScreen> {
  String userId = "";
  String userRole = "";

  List<LocationData> locationList = [];

  String? selectedStateId;
  String? selectedDistrictId;
  String? selectedVillageId;

  String? selectedState;
  String? selectedDistrict;
  String? selectedVillage;

  List<District> districtList = [];
  List<Village> villageList = [];

  IndicatorModel? data;

  @override
  void initState() {
    super.initState();
    getUserInfo();
    if (widget.indicator != null) {
      data = widget.indicator;
      locationList = (data!.indicator_map['location'] as List)
          .map((item) => LocationData.fromJson(item))
          .toList();
    }
  }

  Future<void> getUserInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('user_id') ?? '';
      userRole = prefs.getString('role') ?? '';
    });
  }

  void onStateChanged(String? state_code) {
    setState(() {
      selectedStateId = state_code;
      selectedDistrict = null;
      selectedDistrictId = null;
      selectedVillage = null;
      selectedVillageId = null;

      // Find districts for selected state
      districtList = locationList
          .firstWhere((state) => state.state_code == state_code)
          .districts;
      villageList = [];
    });
  }

  void onDistrictChanged(String? district_code) {
    setState(() {
      selectedDistrictId = district_code;
      selectedVillageId = null;
      selectedVillage = null;

      // Find villages for selected district
      villageList = districtList
          .firstWhere((district) => district.district_code == district_code)
          .villages;
    });
  }

  void onVillageChanged(String? villageId) {
    setState(() {
      selectedVillageId = villageId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dependent Dropdowns')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchDropdownUtils.buildSearchableDropdown<String>(
              items: locationList.map((state) => state.state_name).toList(),
              value: selectedState,
              label: "State",
              icon: Icons.map,
              hint: "Select state",
              onChanged: (value) {
                if (value != null) {
                  onStateChanged(locationList
                      .firstWhere((state) => state.state_name == value)
                      .state_code);
                }
              },
              displayTextFn: (item) => item,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a state";
                }
              },
            ),

            SearchDropdownUtils.buildSearchableDropdown(
              items: districtList.map((e) => e.district_name).toList(),
              value: selectedDistrict,
              label: "District",
              icon: Icons.location_city,
              hint: "Select District",
              onChanged: (value) {
                if (value != null) {
                  onDistrictChanged(districtList
                      .firstWhere((district) => district.district_name == value)
                      .district_code);
                }
              },
              displayTextFn: (item) => item,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a District";
                }
              },
            ),
            SearchDropdownUtils.buildSearchableDropdown(
              items: villageList.map((e) => e.village_name).toList(),
              value: selectedVillage,
              label: "Village",
              icon: Icons.layers,
              hint: "Select village",
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedVillage = value;
                  });
                }
              },
              displayTextFn: (item) => item,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please select a village";
                }
              },
            ),
            // Village Dropdown
          ],
        ),
      ),
    );
  }
}
