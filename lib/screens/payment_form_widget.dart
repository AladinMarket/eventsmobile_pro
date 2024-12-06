import 'package:eventright_pro_user/controller/paid_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentFormWidget extends StatefulWidget {
  final String paymentMethod;
  final String mTotal;

  const PaymentFormWidget(
      {super.key, required this.paymentMethod, required this.mTotal});

  @override
  _PaymentFormWidgetState createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final PaidController paidController = Get.put(PaidController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    paidController.montant = widget.mTotal;
    paidController.paymentMethod = widget.paymentMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paiement")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Form(
          key: paidController.formKey,
          child: Column(
            children: [
              const SizedBox(height: 50),
              Text(
                "Paiement d'un montant de ${paidController.montant}",
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: paidController.number,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: paidController.paymentMethod == "orangeMoney"
                      ? 'Numéro Orange Money'
                      : 'Numéro Moov Money',
                  hintStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                ),
                validator: paidController.numberValidator,
              ),
              if (paidController.paymentMethod == "orangeMoney") ...[
                const SizedBox(height: 20),
                Text(
                  "Composez *144*4*6*${widget.mTotal}# ou générez.",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        makePhoneCall('*144*4*6*${widget.mTotal}#');
                      },
                      child: const Text(
                        "Générer le code otp.",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: paidController.otpCode,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Code OTP',
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  validator: paidController.otpCodeValidator,
                ),
              ],
              const SizedBox(height: 15),
              Obx(() => ElevatedButton(
                    onPressed: () {
                      if (paidController.formKey.currentState!.validate()) {
                        if (paidController.paymentMethod == "orangeMoney") {
                          paidController.validateOrangeMoneyPaid();
                        } else {
                          paidController.initiateMoovMoneyPaid();
                        }
                      }
                    },
                    child: paidController.getLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Valider",
                            style:
                                TextStyle(fontSize: 20.0, color: Colors.white),
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}
