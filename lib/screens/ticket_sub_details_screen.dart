import 'package:coupon_uikit/coupon_uikit.dart';

// TODO: Seat Mapping Module: Step 5: Uncomment Following if you want to add this module
// import 'package:eventright_pro_user/SeatMap/seating_screen.dart';
import 'package:eventright_pro_user/constant/app_const_font.dart';
import 'package:eventright_pro_user/constant/app_constant.dart';
import 'package:eventright_pro_user/constant/color_constant.dart';
import 'package:eventright_pro_user/constant/common_function.dart';
import 'package:eventright_pro_user/constant/pref_constants.dart';
import 'package:eventright_pro_user/constant/preferences.dart';
import 'package:eventright_pro_user/localization/localization_constant.dart';
import 'package:eventright_pro_user/provider/ticket_provider.dart';
import 'package:eventright_pro_user/screens/coupon_screen.dart';
import 'package:eventright_pro_user/screens/payment_form_widget.dart';
import 'package:eventright_pro_user/screens/payment_gateway_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';

class TicketSubDetails extends StatefulWidget {
  final String? ticketType;
  final int isSeatMapModuleInstalled;
  final int? seatMapId;
  final String eventStartDate;
  final String eventEndDate;
  const TicketSubDetails({super.key, this.ticketType, required this.isSeatMapModuleInstalled, this.seatMapId, required this.eventStartDate, required this.eventEndDate});

  @override
  State<TicketSubDetails> createState() => _TicketSubDetailsState();
}

class _TicketSubDetailsState extends State<TicketSubDetails> {
  int quantity = 1;
  late TicketProvider ticketProvider;
  int totalAmount = 0;
  double discountAmount = 0;
  int couponID=0;
  String couponCode = '';

  // ignore: prefer_typing_uninitialized_variables
  var result;

  @override
  void initState() {
    ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    setAmount();

    super.initState();
  }

  void setAmount() async {
    setState(() {
      totalAmount = ticketProvider.totalTax + quantity * ticketProvider.price;
    });
  }

  void increment() {
    if (ticketProvider.soldOut != true) {
      if (quantity < ticketProvider.tickerPerOrder) {
        if(quantity!=ticketProvider.ticketQuantity-ticketProvider.useTicket){
          quantity++;
          totalAmount = totalAmount + ticketProvider.price;
          if (kDebugMode) {
            print(ticketProvider.ticketQuantity-ticketProvider.useTicket);
          }
        }
        else{
          CommonFunction.toastMessage("Ticket Not Available More Then ${ticketProvider.ticketQuantity-ticketProvider.useTicket}");
        }
      } else {
        CommonFunction.toastMessage("You can not buy more than ${ticketProvider.tickerPerOrder}");
      }
    } else {
      CommonFunction.toastMessage("Ticket Not Available");
    }
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
      totalAmount = totalAmount - ticketProvider.price - discountAmount.toInt();
    }
  }

  @override
  Widget build(BuildContext context) {
    ticketProvider = Provider.of<TicketProvider>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            size: 18,
            color: AppColors.whiteColor,
          ),
        ),
        title: Text(
          getTranslated(context, AppConstant.ticketDetails).toString(),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.whiteColor,
            fontFamily: AppFontFamily.poppinsMedium,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: ModalProgressHUD(
          inAsyncCall: ticketProvider.ticketDetailsLoader,
          progressIndicator: const SpinKitCircle(
            color: AppColors.primaryColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                ticketProvider.eventName,
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.blackColor,
                  fontFamily: AppFontFamily.poppinsMedium,
                ),
              ),
              Text(
                widget.ticketType!,
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.blackColor,
                  fontFamily: AppFontFamily.poppinsMedium,
                ),
              ),
              Text(
                "${getTranslated(context, AppConstant.by)} ${ticketProvider.organizerName}",
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.blueColor,
                  fontFamily: AppFontFamily.poppinsMedium,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${ticketProvider.startDate} - ",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.inputTextColor,
                  fontFamily: AppFontFamily.poppinsRegular,
                ),
              ),
              Text(
                ticketProvider.endDate,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.inputTextColor,
                  fontFamily: AppFontFamily.poppinsRegular,
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              CouponCard(
                height: 210,
                curvePosition: 140,
                curveRadius: 20,
                borderRadius: 10,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                firstChild: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "${getTranslated(context, AppConstant.ticketType)} : ",
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontFamily: AppFontFamily.poppinsMedium,
                            ),
                          ),
                          Text(
                            widget.ticketType!,
                            style: const TextStyle(
                              color: AppColors.inputTextColor,
                              fontSize: 16,
                              fontFamily: AppFontFamily.poppinsMedium,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "${getTranslated(context, AppConstant.price)} : ",
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontFamily: AppFontFamily.poppinsMedium,
                            ),
                          ),
                          Text(
                            ticketProvider.price.toString(),
                            style: const TextStyle(
                              color: AppColors.inputTextColor,
                              fontSize: 16,
                              fontFamily: AppFontFamily.poppinsMedium,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "${getTranslated(context, AppConstant.quantity)} : ",
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontFamily: AppFontFamily.poppinsMedium,
                            ),
                          ),
                          ticketProvider.soldOut != true
                              ? Text(
                                  ticketProvider.qty.toString(),
                                  style: const TextStyle(
                                    color: AppColors.inputTextColor,
                                    fontSize: 16,
                                    fontFamily: AppFontFamily.poppinsMedium,
                                  ),
                                )
                              : Text(
                                  getTranslated(context, AppConstant.soldOut).toString(),
                                  style: const TextStyle(
                                    color: AppColors.inputTextColor,
                                    fontSize: 16,
                                    fontFamily: AppFontFamily.poppinsMedium,
                                  ),
                                ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "${getTranslated(context, AppConstant.time)} : ",
                            style: const TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 16,
                              fontFamily: AppFontFamily.poppinsMedium,
                            ),
                          ),
                          Text(
                            ticketProvider.time,
                            style: const TextStyle(
                              color: AppColors.inputTextColor,
                              fontSize: 16,
                              fontFamily: AppFontFamily.poppinsMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                secondChild: Container(
                  width: double.maxFinite,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.white),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150,
                          child: Text(
                            getTranslated(context, AppConstant.howMuchDoYouWant).toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.blackColor,
                              fontFamily: AppFontFamily.poppinsRegular,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    decrement();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryColor,
                                  ),
                                  child: const Icon(
                                    Icons.remove,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.inputTextColor,
                                  fontFamily: AppFontFamily.poppinsMedium,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    increment();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryColor,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              couponCode == '' && ticketProvider.ticketType.toLowerCase()=="paid"
                  ? InkWell(
                      onTap: () async {
                        result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CouponScreen(finalAmount: totalAmount, eventId: ticketProvider.ticketEventId),
                          ),
                        );

                        if (result != null && result['discountAmount'] != null&&result['coupon_id']!=null) {
                          discountAmount = result['discountAmount'].toDouble();
                          couponCode = result['promoCode'];
                          couponID=result['coupon_id'];
                        }
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, AppConstant.youHaveCouponToApply).toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.inputTextColor,
                                fontFamily: AppFontFamily.poppinsMedium,
                              ),
                            ),
                            Text(
                              getTranslated(context, AppConstant.applyNow).toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.blueColor,
                                fontFamily: AppFontFamily.poppinsMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ticketProvider.ticketType.toLowerCase()=="paid"? Container(
                      padding: const EdgeInsets.all(5),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.inputTextColor, width: 0.2),
                      ),
                      child: Text(
                        couponCode,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.inputTextColor,
                          fontFamily: AppFontFamily.poppinsMedium,
                        ),
                      ),
                    ):const SizedBox(),
              const SizedBox(height: 10),
              couponCode != ''
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTranslated(context, AppConstant.discount).toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFontFamily.poppinsMedium,
                          ),
                        ),
                        Text(
                          SharedPreferenceHelper.getString(Preferences.currencySymbol) + discountAmount.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.inputTextColor,
                            fontFamily: AppFontFamily.poppinsMedium,
                          ),
                        ),
                      ],
                    )
                  : Container(),
              const SizedBox(height: 10),
              ticketProvider.allDay==0?  TextFormField(
                readOnly: true,
                controller: selectedDateController,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: AppFontFamily.poppinsRegular,
                ),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: getTranslated(context, AppConstant.ticketDate).toString(),
                  hintStyle: const TextStyle(
                    color: AppColors.inputTextColor,
                    fontSize: 16,
                    fontFamily: AppFontFamily.poppinsMedium,
                  ),
                ),
                onTap:()=> _selectDate(context),
              ):const SizedBox(),
              ticketProvider.allDay==0?  const SizedBox(height: 10):const SizedBox(),
              ListView.builder(
                  itemCount: ticketProvider.allTax.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ticketProvider.allTax[index].name!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.blackColor,
                              fontFamily: AppFontFamily.poppinsMedium,
                            ),
                          ),
                          Text(
                            SharedPreferenceHelper.getString(Preferences.currencySymbol) + ticketProvider.allTax[index].price!.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFontFamily.poppinsMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
      bottomNavigationBar: InkWell(
        onTap: () {
          if (widget.isSeatMapModuleInstalled == 1&&widget.seatMapId!=0) {
            // TODO: Seat Mapping Module: Step 6: Uncomment Following if you want to add this module
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => SeatingScreen(
            //       eventId: ticketProvider.ticketEventId,
            //       ticketId: ticketProvider.ticketId,
            //       quantity: quantity,
            //       payment: couponCode != '' ? totalAmount - int.parse(discountAmount.toInt().toString()) : totalAmount,
            //       tax: ticketProvider.totalTax.toDouble(),
            //       couponDiscount: discountAmount,
            //       moduleInstall: widget.isSeatMapModuleInstalled,
            //       seatMapId: widget.seatMapId!,
            //     ),
            //   ),
            // );
          } else {
            if(ticketProvider.allDay==0&&selectedDateController.text.isEmpty){
              CommonFunction.toastMessage("Please select ticket date");
            }
            else{
              paymentSheett();
             /* Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentGateway(
                    payment: int.parse(totalAmount.round().toString()),
                    eventId: ticketProvider.ticketEventId,
                    quantity: quantity,
                    couponDiscount: discountAmount,
                    ticketId: ticketProvider.ticketId,
                    tax: ticketProvider.totalTax.toDouble(),
                    ticketType: ticketProvider.ticketType,
                    ticketDate: selectedDateController.text.isNotEmpty?selectedDateController.text:"",
                    couponId: couponID,
                  ),
                ),
              );*/
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.only(left: 05, right: 05, bottom: 05),
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.primaryColor),
          child: Text(
            "${getTranslated(context, AppConstant.continueKey)} ${totalAmount - discountAmount}",
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.whiteColor,
              fontFamily: AppFontFamily.poppinsMedium,
            ),
          ),
        ),
      ),
    );
  }
  DateTime? selectedDate;
  TextEditingController selectedDateController=TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateFormat("dd MMMM yyyy").parse(widget.eventStartDate);
    if (kDebugMode) {
      print(DateTime.now().isBefore(initialDate));
    }
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: initialDate.isBefore(DateTime.now())?DateTime.now():initialDate,
        lastDate: DateFormat("dd MMMM yyyy").parse(widget.eventEndDate)
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedDateController.text= DateFormat('yyyy-MM-dd').format(picked);
        if (kDebugMode) {
          print(selectedDateController.text);
        }
      });
    }
  }


  Future paymentSheett() {
    int _selectedPayment = 0;
    return showModalBottomSheet(
      backgroundColor:  const Color(0xffFFFFFF),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10),
                      Center(
                        child: Container(
                          height: Get.height / 80,
                          width: Get.width / 5,
                          decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                        ),
                      ),
                      SizedBox(height: Get.height / 50),
                      Row(children: [
                        SizedBox(width: Get.width / 14),
                        const Text("Select Payment Method",
                            style: TextStyle(
                                color: Color(0xff000000),
                                fontSize: 15,
                                fontFamily:"Ubuntu Light")),
                      ]),
                      SizedBox(height: Get.height / 50),
                      //! --------- List view paymente ----------
                      // Variable pour suivre la sélection

                      SizedBox(
                        height: Get.height * 0.30,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: sugestlocationtype(
                                borderColor: _selectedPayment == 0
                                    ? Color(0xff2f6ee6)
                                    : const Color(0xffD6D6D6),
                                title: "Orange Money",
                                titleColor: const Color(0xff000000),
                                val: 0,
                                image:'assets/orangemoney.png',
                                adress: "Payer directement avec Orange Money",
                                ontap: () {
                                  setState(() {
                                    _selectedPayment = 0;

                                  });
                                },
                                radio: Radio(
                                  activeColor: Color(0xff2f6ee6),
                                  value: 0,
                                  groupValue: _selectedPayment,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPayment = value as int;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: sugestlocationtype(
                                borderColor: _selectedPayment == 1
                                    ? const Color(0xff2f6ee6)
                                    : const Color(0xffD6D6D6),
                                title: "Moov Money",
                                titleColor: const Color(0xff000000),
                                val: 1,
                                image:'assets/moovmoney.png',
                                adress: "Payer directement avec Moov Money",
                                ontap: () {
                                  setState(() {
                                    _selectedPayment = 1;

                                  });
                                },
                                radio: Radio(
                                  activeColor: Color(0xff2f6ee6),
                                  value: 1,
                                  groupValue: _selectedPayment,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPayment = value as int;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        height: 80,
                        width: Get.size.width,
                        alignment: Alignment.center,
                        child: GestButton(
                          Width: Get.size.width,
                          height: 50,
                          buttoncolor: Color(0xff2f6ee6),
                          margin: EdgeInsets.only(top: 10, left: 30, right: 30),
                          buttontext: "Continue",
                          style: TextStyle(
                            fontFamily: "Ubuntu Light",
                            color: const Color(0xffFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          onclick: () async {

                            if(_selectedPayment == 1){
                              Get.to( PaymentFormWidget(paymentMethod: 'moovMoney',mTotal: totalAmount.round().toString(),));
                            }else{
                              Get.to(PaymentFormWidget(paymentMethod: 'orangeMoney',mTotal: totalAmount.round().toString()));
                            }
                            //!---- Stripe Payment ------
                          },
                        ),
                        decoration: BoxDecoration(
                          color:const Color(0xffFFFFFF),
                        ),
                      ),
                    ],
                  );
                }),
          ],
        );
      },
    );
  }
  Widget sugestlocationtype(
      {Function()? ontap,
        title,
        val,
        image,
        adress,
        radio,
        Color? borderColor,
        Color? titleColor}) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return InkWell(
            splashColor: Colors.transparent,
            onTap: ontap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Get.width / 18),
              child: Container(
                height: Get.height / 10,
                decoration: BoxDecoration(
                    border: Border.all(color: borderColor!, width: 1),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(11)),
                child: Row(
                  children: [
                    SizedBox(width: Get.width / 55),
                    Container(
                        height: Get.height / 12,
                        width: Get.width / 5.5,
                        decoration: BoxDecoration(
                            color: const Color(0xffF2F4F9),
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: FadeInImage(
                              placeholder: const AssetImage("assets/loading2.gif"),
                              image: AssetImage(image)),
                          // Image.network(image, height: Get.height / 08)
                        )),
                    SizedBox(width: Get.width / 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: Get.height * 0.01),
                        Text(title,
                            style: TextStyle(
                              fontSize: Get.height / 55,
                              fontFamily:"Ubuntu Light",
                              color: titleColor,
                            )),
                        SizedBox(
                          width: Get.width * 0.50,
                          child: Text(adress,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: Get.height / 65,
                                  fontFamily: 'Gilroy_Medium',
                                  color: Colors.grey)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    radio
                  ],
                ),
              ),
            ),
          );
        });
  }
  GestButton({
    String? buttontext,
    Function()? onclick,
    double? Width,
    double? height,
    Color? buttoncolor,
    EdgeInsets? margin,
    TextStyle? style,
  }) {
    return GestureDetector(
      onTap: onclick,
      child: Container(
        height: height,
        width: Width,
        // margin: EdgeInsets.only(top: 15, left: 30, right: 30),
        margin: margin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          // color: buttoncolor,
          gradient: const LinearGradient(
            colors: [Color(0xff2f6ee6), Color(0xff2f6ee6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: const Offset(
                0.5,
                0.5,
              ),
              blurRadius: 1,
            ),
          ],
        ),
        child: Text(buttontext!, style: style),
      ),
    );
  }
}
