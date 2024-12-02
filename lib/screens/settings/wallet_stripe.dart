import 'package:eventright_pro_user/constant/app_const_font.dart';
import 'package:eventright_pro_user/constant/app_constant.dart';
import 'package:eventright_pro_user/constant/color_constant.dart';
import 'package:eventright_pro_user/constant/pref_constants.dart';
import 'package:eventright_pro_user/constant/preferences.dart';
import 'package:eventright_pro_user/localization/localization_constant.dart';
import 'package:eventright_pro_user/provider/wallet_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class WalletStripe extends StatefulWidget {
  final String amount;

  const WalletStripe({super.key, required this.amount});

  @override
  State<WalletStripe> createState() => _WalletStripeState();
}

class _WalletStripeState extends State<WalletStripe> {
  stripe.CardFieldInputDetails? _card;

  stripe.TokenData? tokenData;
  List catId = [];
  String convertedJson = "";

  late WalletProvider walletProvider;

  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    setKey();
  }

  Future setKey() async {
    stripe.Stripe.publishableKey = SharedPreferenceHelper.getString(Preferences.stripPublicKey);
    await stripe.Stripe.instance.applySettings();
  }

  @override
  Widget build(BuildContext context) {
    walletProvider = Provider.of<WalletProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.whiteColor,
          ),
        ),
        title: Text(
          getTranslated(context, AppConstant.stripe).toString(),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.whiteColor,
            fontFamily: AppFontFamily.poppinsMedium,
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: walletProvider.bookOrderLoader,
        progressIndicator: const SpinKitCircle(color: AppColors.primaryColor),
        child: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: stripe.CardField(
                    autofocus: true,
                    onCardChanged: (card) {
                      setState(() {
                        _card = card;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _card?.complete == true ? _handleCreateTokenPress : null,
                    child: Text(
                      getTranslated(context, AppConstant.payment).toString(),
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontFamily: AppFontFamily.poppinsMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateTokenPress() async {
    if (_card == null) {
      return;
    }

    try {
      final tokenData = await stripe.Stripe.instance.createToken(
        const stripe.CreateTokenParams.card(
          params: CardTokenParams(
            type: TokenType.Card,
          ),
        ),
      );
      setState(() {
        this.tokenData = tokenData;
        Map<String, dynamic> body = {
          "amount": widget.amount,
          "payment_type": "STRIPE",
          "token": tokenData.id,
          "currency": SharedPreferenceHelper.getString(Preferences.currencyCode),
        };
        if (kDebugMode) {
          print(body);
        }
        if (tokenData.id != '') {
          walletProvider.callApiForWalletDeposit(body).then((value) {
            if (value.data!.success == true) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
          });
        }
      });

      return;
    } catch (e) {
      rethrow;
    }
  }
}
