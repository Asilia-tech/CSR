import 'package:sterlite_csr/models/district_model.dart';
import 'package:sterlite_csr/models/state_model.dart';
import 'package:sterlite_csr/models/village_model.dart';

class LocationUtils {
  static Map<String, List<String>> extractSelectedLocations(
      List<Map<String, dynamic>> locationList) {
    List<String> selectedState = [];
    List<String> selectedDistrict = [];
    List<String> selectedVillage = [];

    for (var state in locationList) {
      selectedState.add(state['state_name'] as String);

      for (var district in state['districts'] as List<dynamic>) {
        selectedDistrict.add(district['district_name'] as String);

        for (var village in district['villages'] as List<dynamic>) {
          selectedVillage.add(village['village_name'] as String);
        }
      }
    }

    return {
      'selectedState': selectedState,
      'selectedDistrict': selectedDistrict,
      'selectedVillage': selectedVillage,
    };
  }

  static List<Map<String, dynamic>> convertToNestedLocationFormat(
    List<StateModel> stateOptions,
    List<DistrictModel> districtOptions,
    List<VillageModel> villageOptions,
    List<String> selectedState,
    List<String> selectedDistrict,
    List<String> selectedVillage,
  ) {
    final selectedStates = stateOptions
        .where((state) => selectedState.contains(state.name))
        .toList();

    List<Map<String, dynamic>> location = selectedStates.map((state) {
      final stateDistricts = districtOptions
          .where((district) =>
              selectedDistrict.contains(district.name) &&
              district.state_code == state.state_code)
          .toList();

      final districts = stateDistricts.map((district) {
        final districtVillages = villageOptions
            .where((village) =>
                selectedVillage.contains(village.name) &&
                village.district_code == district.district_code)
            .map((village) => {
                  'village_code': village.village_code,
                  'village_name': village.name,
                })
            .toList();

        return {
          'district_code': district.district_code,
          'district_name': district.name,
          'villages': districtVillages,
        };
      }).toList();

      return {
        'state_code': state.state_code,
        'state_name': state.name,
        'districts': districts,
      };
    }).toList();

    return location;
  }
}
