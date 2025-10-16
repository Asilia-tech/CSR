import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sterlite_csr/utilities/function_utils.dart';

class APIController extends GetxController {
  RxBool isLoading = false.obs;

  fetchData(String uri, Map params) async {
    try {
      isLoading(true);
      http.Response response =
          await http.post(Uri.parse(uri), body: jsonEncode(params));
      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);
        return result;
      } else {
        return {
          "message": Utils.errorServer(response.statusCode),
          "isValid": false
        };
      }
    } catch (e) {
      return {"message": 'Something went wrong...$e', "isValid": false};
    } finally {
      isLoading(false);
    }
  }
}
