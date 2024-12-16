import 'dart:convert';

import 'package:eventright_pro_user/controller/paid_controller.dart';
import 'package:eventright_pro_user/provider/book_order_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentFormWidget extends StatefulWidget {
  final String paymentMethod;
  final String payment;
  final int? eventId;
  final int? quantity;
  final double? couponDiscount;
  final int? ticketId;
  final double? tax;
  final List? seatDetails;
  final List? bookSeats;
  final String ticketType;
  final String? ticketDate;
  final int couponId;
  const PaymentFormWidget(
      {super.key, required this.paymentMethod,required this.payment, this.eventId, this.quantity, this.couponDiscount, this.ticketId, this.tax, this.seatDetails, this.bookSeats, required this.ticketType, this.ticketDate, required this.couponId});

  @override
  _PaymentFormWidgetState createState() => _PaymentFormWidgetState();
}

class _PaymentFormWidgetState extends State<PaymentFormWidget> {
  final PaidController paidController = Get.put(PaidController());
  late BookOrderProvider bookOrderProvider;
  List catId = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bookOrderProvider = Provider.of<BookOrderProvider>(context, listen: false);
    paidController.bookOrderProvider = bookOrderProvider;
    paidController.montant =  widget.payment;
    paidController.paymentMethod = widget.paymentMethod;
    paidController.payment = widget.payment;
    paidController.eventId = widget.eventId;
    paidController.quantity = widget.quantity;
    paidController.couponDiscount = widget.couponDiscount;
    paidController.ticketId = widget.ticketId;
    paidController.tax = widget.tax;
    paidController.seatDetails = widget.seatDetails;
    paidController.bookSeats = widget.bookSeats;
    paidController.ticketType = widget.ticketType;
    paidController.ticketDate = widget.ticketDate;
    paidController.couponId = widget.couponId;

    Map<String, dynamic> map;
    if (widget.seatDetails != null) {
      for (int i = 0; i < widget.seatDetails!.length; i++) {
        map = {
          "row": widget.seatDetails![i].toString().split("-")[0],
          "seat": widget.seatDetails![i].toString().split("-")[1],
        };
        catId.add(map);
      }
      paidController.convertedJson = jsonEncode(catId);
      if (kDebugMode) {
        print("converted=================>:${paidController.convertedJson}");
      }
    }
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
                  "Composez *144*4*6*${widget.payment}# ou générez.",
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
                        makePhoneCall('*144*4*6*${widget.payment}#');
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
                          paidController.validateOrangeMoneyPaid(context);
                        } else {
                          paidController.initiateMoovMoneyPaid(context);
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
