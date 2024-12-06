import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
///import 'package:http_auth/http_auth.dart';
import 'package:http/http.dart' as http;


class PaidController extends GetxController {
  TextEditingController number = TextEditingController();
  TextEditingController otpCode = TextEditingController();
  String montant = "0";
  String paymentMethod = "";
  String transactionIdToCheck = "";

  final formKey = GlobalKey<FormState>();
  RxBool getLoading = false.obs;



  String? numberValidator(String? value) {
    if (value!.isEmpty) {
      return "Numéro Orange Money non renseigné.";
    }
    return null;
  }

  String? otpCodeValidator(String? value) {
    if (paymentMethod == "orangeMoney" && value!.isEmpty) {
      return "Veuillez renseigner le code otp.";
    }
    return null;
  }

// new
  Future<void> validateOrangeMoneyPaid() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    getLoading.value = true;
    final data = {
      'user_id': 1,
      'otp_code': otpCode.text,
      'phone_number': number.text,
      'amount': int.parse(double.parse(montant).round().toString()),
    };
    const url = 'https://events.aladinmarket-bf.com/api/orange_money/payment';
    final header = {"Content-Type": "application/json; charset=UTF-8"};
    try {
      final response =
          await http.post(Uri.parse(url), body: data, headers: header);
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'SUCCESSFUL') {
        // tout autre traitement ici comme le recu etc
        await customSuccessDialog();

      } else {
        Get.snackbar(
          "Échec du paiement",
          "Le paiement n'a pas pu être complété. Veuillez réessayer.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      var errorMessage = e.toString();
      Get.snackbar(
        "Erreur",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      getLoading.value = false;
    }
  }

  Future<void> initiateMoovMoneyPaid() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    getLoading.value = true;
    transactionIdToCheck = "";

    final data = {
      'user_id': 1,
      'phone_number': number.text,
      'amount': int.parse(double.parse(montant).round().toString()),
    };
    const url = 'https://events.aladinmarket-bf.com/api/moov_money/initialise';
    final header = {"Content-Type": "application/json; charset=UTF-8"};
    try {
      final response =
          await http.post(Uri.parse(url), body: data, headers: header);
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'INITIATED') {
        transactionIdToCheck = responseData['idFromClient'];
        // tout autre traitement ici comme le recu etc
        await customPendingDialog();
      } else {
        Get.snackbar(
          "Échec du paiement",
          "Le paiement n'a pas pu être complété. Veuillez réessayer.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      var errorMessage = e.toString();
      Get.snackbar(
        "Erreur",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      //
    }
  }

  Future<void> validateMoovMoneyPaid() async {
    final url =
        'https://events.aladinmarket-bf.com/api/moov_money/check_status/$transactionIdToCheck';
    final header = {"Content-Type": "application/json; charset=UTF-8"};
    try {
      final response = await http.get(Uri.parse(url), headers: header);
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'SUCCEED') {
        await customSuccessDialog();

      } else {
        Get.snackbar(
          "Échec du paiement",
          "Le paiement n'a pas pu être complété. Veuillez réessayer.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      var errorMessage = e.toString();
      Get.snackbar(
        "Erreur",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      getLoading.value = false;
    }
  } //end new
  /*  Future<void> validateOrangeMoneyPaid() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    getLoading.value = true;
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
    final data = {
      'idFromClient': transactionId,
      'additionnalInfos': {
        'destinataire': number.text,
        'otp': otpCode.text,
      },
      'amount': int.parse(double.parse(montant).round().toString()),
      'callback': 'https://events.aladinmarket-bf.com',
      'recipientNumber': number.text,
      'serviceCode': 'BF_PAIEMENTMARCHAND_OM_TP',
    };
    const url =
        'https://api.gutouch.com/dist/api/touchpayapi/v1/GTSBF2917/transaction?loginAgent=56365685&passwordAgent=ZVHLZjQPBc';
    try {
      final responseData = await makePutApiCall(url, data);
      if (responseData['status'] == 'SUCCESSFUL') {
        // tout autre traitement ici comme le recu etc
        await customSuccessDialog();
        bookEventController.bookEventApi(
          eID: eventDetailsController.eventInfo?.eventData.eventId, // ID d'événement en dur
          typeId: eventDetailsController.ticketID,
          type: eventDetailsController.ticketInfo?.eventTypePrice,
          price: eventDetailsController.mTotal,
          totalTicket: eventDetailsController.totalTicket,
          subTotal: eventDetailsController.mTotal,
          tax: 0.0,
          couAmt: eventDetailsController.mTotal,
          totalAmt: eventDetailsController.mTotal,
          wallAmt: 0,
          pMethodId: "11",
          otid: "TXVB060504",
          pLimit: "10",
          sponsoreId: eventDetailsController.eventInfo?.eventData.sponsoreId,
        );
      } else {
        Get.snackbar(
          "Échec du paiement",
          "Le paiement n'a pas pu être complété. Veuillez réessayer.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      var errorMessage = e.toString();
      Get.snackbar(
        "Erreur",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      getLoading.value = false;
    }
  }*/
  /*Future<void> initiateMoovMoneyPaid() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    getLoading.value = true;
    transactionIdToCheck = "";
    final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
    transactionIdToCheck = transactionId;
    final data = {
      'idFromClient': transactionId,
      'additionnalInfos': {
        'destinataire': number.text,
      },
      'amount': int.parse(double.parse(montant).round().toString()),
      'callback': 'https://gutouch.com',
      'recipientNumber': number.text,
      'serviceCode': 'BF_PAIEMENTMARCHAND_MOBICASH_TP',
    };
    const url =
        'https://api.gutouch.com/dist/api/touchpayapi/v1/GTSBF2917/transaction?loginAgent=56365685&passwordAgent=ZVHLZjQPBc';
    try {
      final responseData = await makePutApiCall(
        url,
        data,
      );
      if (responseData['status'] == 'INITIATED') {
        // tout autre traitement ici comme le recu etc
        await customPendingDialog();
      } else {
        Get.snackbar(
          "Échec du paiement",
          "Le paiement n'a pas pu être complété. Veuillez réessayer.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      var errorMessage = e.toString();
      Get.snackbar(
        "Erreur",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      //
    }
  }*/
  /*Future<void> validateMoovMoneyPaid() async {
    final url =
        'https://api.gutouch.com/dist/api/touchpayapi/v1/GTSBF2917/transaction/$transactionIdToCheck?loginAgent=56365685&passwordAgent=ZVHLZjQPBc';
    try {
      final responseData = await makeGetApiCall(url);
      if (responseData['status'] == 'SUCCEED') {
        await customSuccessDialog();
        bookEventController.bookEventApi(
          eID: eventDetailsController.eventInfo?.eventData.eventId, // ID d'événement en dur
          typeId: eventDetailsController.ticketID,
          type: eventDetailsController.ticketInfo?.eventTypePrice,
          price: eventDetailsController.mTotal,
          totalTicket: eventDetailsController.totalTicket,
          subTotal: eventDetailsController.mTotal,
          tax: 0.0,
          couAmt: eventDetailsController.mTotal,
          totalAmt: eventDetailsController.mTotal,
          wallAmt: 0,
          pMethodId: "11",
          otid: "TXVB060504",
          pLimit: "10",
          sponsoreId: eventDetailsController.eventInfo?.eventData.sponsoreId,
        );
      } else {
        Get.snackbar(
          "Échec du paiement",
          "Le paiement n'a pas pu être complété. Veuillez réessayer.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      var errorMessage = e.toString();
      Get.snackbar(
        "Erreur",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      getLoading.value = false;
    }
  }*/

/*  Future<Map<String, dynamic>> makeGetApiCall(
      String url) async {
    const username =
        '5aeb3edb2011240b10d3afa8fff7c6e894115b10b81db4ac86c69156e9d0d175';
    const password =
        '0db8f48f12b2f5288ddb528a37ef24205079fd831f3f410b0f6f6efdb0dc1501';
    var client = DigestAuthClient(username, password);
    final uri = Uri.parse(url);
    try {
      final response = await client.get(uri,
        headers: {'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var responseJson = jsonDecode(response.body);
        var errorMessage = responseJson['detailMessage'] ?? 'Erreur inconnue';
        throw Exception('Erreur $errorMessage');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'appel API: $e');
    }
  }*/

/*  Future<Map<String, dynamic>> makePutApiCall(
      String url, Map<String, dynamic> data) async {
    const username =
        '5aeb3edb2011240b10d3afa8fff7c6e894115b10b81db4ac86c69156e9d0d175';
    const password =
        '0db8f48f12b2f5288ddb528a37ef24205079fd831f3f410b0f6f6efdb0dc1501';
    var client = DigestAuthClient(username, password);
    final uri = Uri.parse(url);
    try {
      final response = await client.put(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(data));
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var responseJson = jsonDecode(response.body);
        var errorMessage = responseJson['detailMessage'] ?? 'Erreur inconnue';
        throw Exception('Erreur $errorMessage');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'appel API: $e');
    }
  }*/

  Future<void> customPendingDialog() {
    return Get.defaultDialog(
      title: "",
      titleStyle: TextStyle(fontSize: 0.0),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      barrierDismissible: false,
      content: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                //ou ici tout autre traitement comme le recu ou redirection
              },
              icon: Icon(Icons.close),
            ),
          ),
          const Image(
            image: AssetImage('assets/success.gif'),
            height: 50,
            width: 50,
          ),
          const Text(
            "En attente",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 42.0,
              color: Colors.black87,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Votre paiement est en attente, veuillez consulter vos message et une fois terminer cliquer sur le bouton vérifier.",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              validateMoovMoneyPaid();
            },
            child: const Text(
              "Vérifier",
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
        ],
      ),
      radius: 15,
    );
  }

  Future<void> customSuccessDialog() {
    return Get.defaultDialog(
      title: "",
      titleStyle: TextStyle(fontSize: 0.0),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      barrierDismissible: false,
      content: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                //ou ici tout autre traitement comme le recu ou redirection
                Get.back();
              },
              icon: Icon(Icons.close),
            ),
          ),
          const Image(
            image: AssetImage('assets/success.gif'),
            height: 50,
            width: 50,
          ),
          const Text(
            "Succès",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 42.0,
              color: Colors.black87,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              "Votre paiement est effectué avec succès.",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
      radius: 15,
    );
  }

  @override
  void onInit() {
    super.onInit();
  }
}
