import 'dart:convert';

import 'package:constata_0_0_2/src/features/effective_process/controllers/effective_jarvis.dart';
import 'package:constata_0_0_2/src/features/effective_process/data/appointment_data.dart';
import 'package:constata_0_0_2/src/features/effective_process/models/effective_model.dart';
import 'package:constata_0_0_2/src/features/effective_process/quantity_form.dart';
import 'package:constata_0_0_2/src/shared/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ApointmentEffectiveReworked extends StatefulWidget {
  final date;

  final dataLogged;
  final editingMode;

  const ApointmentEffectiveReworked(
      {Key key, this.dataLogged, this.date, this.editingMode = false})
      : super(key: key);

  @override
  _ApointmentEffectiveReworkedState createState() =>
      _ApointmentEffectiveReworkedState();
}

class _ApointmentEffectiveReworkedState
    extends State<ApointmentEffectiveReworked> {
  // var descriptionController = TextEditingController();
  var cafeManhaController = TextEditingController();
  var cafeTardeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Effective> effectives = [];
  EffectiveController effectiveController = EffectiveController();
  String nomeObra;
  @override
  void initState() {
    nomeObra = widget.dataLogged['obra']['data']['tb01_cp002'];
    initializer();
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
  }

  bool editingMode = false;

  @override
  void dispose() {
    super.dispose();
  }

  void initializer() async {
    if (widget.editingMode == true) {
      _effectiveApointment =
          Provider.of<AppointmentData>(context, listen: false).appointmentData;
      effectives = Provider.of<AppointmentData>(context, listen: false)
          .appointmentData
          .data
          .effective;
      _morningQuantity.text =
          Provider.of<AppointmentData>(context, listen: false)
              .appointmentData
              .data
              .morningQuantity;
      _afternoonQuantity.text =
          Provider.of<AppointmentData>(context, listen: false)
              .appointmentData
              .data
              .afternoonQuantity;
      setState(() {});
    } else {
      await fetchEffective();
    }
  }

  Future<void> fetchEffective() async {
    effectives = await effectiveController
        .fetchEffective(context: context, buildName: nomeObra)
        .onError((error, stackTrace) async {
      return await offlineEffectives();
    });

    effectives.sort(((a, b) => a.effectiveName.compareTo(b.effectiveName)));

    setState(() {});
  }

  Future<List<Effective>> offlineEffectives() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<Effective> list = [];
    if (sharedPreferences.containsKey("colaboradores")) {
      var effectiveList =
          jsonDecode(sharedPreferences.getString("colaboradores"));

      Uuid uuid = Uuid();

      for (var i = 0; i < effectiveList.length; i++) {
        var a = Effective(
            effectiveCode: effectiveList[i]['data']['tb01_cp004'],
            effectiveFixed: '',
            effectiveName: effectiveList[i]['data']['tb01_cp002'],
            effectiveStatus: '',
            id: uuid.v4());
        list.add(a);
      }
      print(list.length);
    }
    return list;
  }

  void changeStatus(index, value) {
    setState(() {
      effectives[index].effectiveStatus = value;
    });
  }

  EffectiveApointment _effectiveApointment;
  void send() async {
    _effectiveApointment = EffectiveApointment(
        data: DataBody(
            address: widget.dataLogged['local_negocio']['name'],
            buildName: BuildName.fromJson(widget.dataLogged['obra']),
            code: null,
            companyName: CompanyName.fromJson(widget.dataLogged['empresa']),
            datetime: widget.date,
            description: 'Descrição do apontamento',
            effective: effectives,
            morningQuantity: _morningQuantity.text,
            afternoonQuantity: _afternoonQuantity.text,
            pointer: widget.dataLogged['user']['name'],
            segment: widget.dataLogged['obra']['data']['tb01_cp026']['name'],
            type: "EFET"));

    final response = await effectiveController.sendEffective(
        context: context, efetivo: _effectiveApointment);

    if (response == 'created') {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('Apontamento enviado!'),
              content: Text(
                  'Os demais serviços estarão disponíveis na data desse efetivo!'),
            );
          }).then((value) => Navigator.of(context).pop());
      Provider.of<AppointmentData>(context, listen: false)
          .clearAppointmentData();
    }
    if (response == 'offline') {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('Apontamento não enviado!'),
              content: Text('O apontamento está pendente de envio!'),
            );
          });
    }
  }

  void save() async {
    _effectiveApointment = EffectiveApointment(
        data: DataBody(
            address: widget.dataLogged['local_negocio']['name'],
            buildName: BuildName.fromJson(widget.dataLogged['obra']),
            code: null,
            companyName: CompanyName.fromJson(widget.dataLogged['empresa']),
            datetime: widget.date,
            description: 'Descrição do apontamento',
            effective: effectives,
            morningQuantity: _morningQuantity.text,
            afternoonQuantity: _afternoonQuantity.text,
            pointer: widget.dataLogged['user']['name'],
            segment: widget.dataLogged['obra']['data']['tb01_cp026']['name'],
            type: "EFET"));
  }

  Future<bool> returnScreenAlert(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Sair do apontamento'),
            content: Text('Deseja salvar um rascunho?'),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        Provider.of<AppointmentData>(context, listen: false)
                            .clearAppointmentData();
                        Navigator.pop(context, true);
                        Navigator.pop(context);
                      },
                      child: const Text('Não')),
                  TextButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    CircularProgressIndicator(),
                                    Text('Salvando...')
                                  ],
                                ),
                              );
                            });
                        save();
                        Provider.of<AppointmentData>(context, listen: false)
                            .setAppointmentData(_effectiveApointment);
                        print(
                            Provider.of<AppointmentData>(context, listen: false)
                                .appointmentData
                                .data
                                .effective
                                .first
                                .effectiveName);
                        await Future.delayed(Duration(seconds: 1));
                        Navigator.of(context).pop();
                        Navigator.pop(context, true);
                      },
                      child: const Text('Sim')),
                ],
              )
            ],
          );
        });
  }

  TextEditingController _morningQuantity = TextEditingController();
  TextEditingController _afternoonQuantity = TextEditingController();

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 28),
      backgroundColor: Palette.customSwatch,
      visible: true,
      curve: Curves.bounceInOut,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.send, color: Colors.white),
          backgroundColor: Palette.customSwatch,
          onTap: () => sendValidator(),
          label: 'Enviar',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: const Icon(Icons.check, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => updateAll('Presente'),
          label: 'Completar presenças',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
        SpeedDialChild(
          child: const Icon(Icons.cancel_outlined, color: Colors.white),
          backgroundColor: Colors.red,
          onTap: () => updateAll('Ausente'),
          label: 'Completar Ausências',
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Colors.black,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Apontamento';
    try {
      title = 'Rascunho - ' +
          Provider.of<AppointmentData>(context, listen: false)
              .appointmentData
              .data
              .datetime;
    } catch (e) {
      title = 'Apontamento - ${widget.date}';
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldSave = await returnScreenAlert(context);

        print(shouldSave);
        return shouldSave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
            child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                        child: QuantityForm(
                      controller: _morningQuantity,
                      hintText: 'Cafés da manhã',
                    )),
                    Flexible(
                        child: QuantityForm(
                      controller: _afternoonQuantity,
                      hintText: 'Cafés da tarde',
                    )),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: effectives != null && effectives.isNotEmpty
                        ? effectives.length
                        : 0,
                    itemBuilder: (BuildContext context, int index) {
                      var effective = effectives[index];
                      return Slidable(
                        key: ValueKey(index),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          closeThreshold: 0.1,
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                changeStatus(index, 'Em Transferência');
                              },
                              autoClose: true,
                              flex: 3,
                              backgroundColor:
                                  Color.fromARGB(255, 230, 167, 23),
                              foregroundColor: Colors.white,
                              spacing: 4,
                              borderRadius: BorderRadius.circular(8),
                              padding: EdgeInsets.all(2),
                              icon: Icons.call_split,
                              label: 'Transferência',
                            ),
                            SlidableAction(
                              onPressed: (context) {
                                changeStatus(index, 'Ausente');
                              },
                              autoClose: true,
                              flex: 2,
                              borderRadius: BorderRadius.circular(8),
                              backgroundColor: Color.fromARGB(255, 199, 37, 37),
                              foregroundColor: Colors.white,
                              spacing: 4,
                              padding: EdgeInsets.all(2),
                              icon: Icons.cancel_outlined,
                              label: 'Ausente',
                            ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          closeThreshold: 0.1,
                          dismissible: DismissiblePane(
                            confirmDismiss: () async {
                              print('confirm');
                              changeStatus(index, 'Presente');
                              return false;
                            },
                            closeOnCancel: true,
                            dismissThreshold: 0.02,
                            onDismissed: () {},
                          ),
                          extentRatio: 0.01,
                          children: [
                            SlidableAction(
                              onPressed: (context) {},
                              autoClose: true,
                              flex: 1,
                              backgroundColor: Color(0xFF7BC043),
                              foregroundColor: Colors.white,
                              spacing: 0,
                              padding: EdgeInsets.all(8),
                              borderRadius: BorderRadius.circular(8),
                              icon: Icons.check,
                              label: 'Presente',
                            ),
                          ],
                        ),
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 1,
                                    color: effective.effectiveStatus == ''
                                        ? Colors.red.withOpacity(.5)
                                        : Colors.transparent),
                              ],
                              // color: effective.effectiveStatus == ""
                              //     ? Color.fromARGB(255, 230, 60, 60)
                              //     : Colors.white,
                              borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(vertical: 1),
                          margin: EdgeInsets.all(2),
                          duration: Duration(seconds: 2),
                          curve: Curves.easeOutCirc,
                          child: Card(
                            color: effective.effectiveStatus == ''
                                ? Colors.grey.shade100
                                : Colors.white,
                            // shadowColor: effective.effectiveStatus == ''
                            //     ? Color.fromARGB(255, 247, 0, 0)
                            //     : Colors.black,
                            elevation: effective.effectiveStatus == '' ? 5 : 1,
                            child: Column(
                              children: [
                                ListTile(
                                    leading: effective.effectiveStatus != ""
                                        ? null
                                        : Icon(
                                            Icons.arrow_forward,
                                            color: Colors.grey.shade400,
                                          ),
                                    title: Text(
                                      effective.effectiveName +
                                          '\n' +
                                          effective.effectiveCode,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      effective.effectiveStatus,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: effective.effectiveStatus ==
                                                  "Presente"
                                              ? Colors.green
                                              : Colors.red),
                                    ),
                                    trailing: effective.effectiveStatus != ""
                                        ? null
                                        : Icon(
                                            Icons.arrow_back,
                                            color: Colors.grey.shade400,
                                          )),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        )),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndDocked,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomAppBar(
            color: Palette.customSwatch,
            child: Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 8,
                ),
                Text(
                  '${effectives.length} funcionários cadastrados',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )
              ],
            ),
            shape: CircularNotchedRectangle()),
        floatingActionButton: buildSpeedDial(),
      ),
    );
  }

  void updateAll(String value) {
    for (var effective in effectives) {
      if (effective.effectiveStatus == '') {
        effective.effectiveStatus = value;
      }
    }
    setState(() {});
  }

  void sendValidator() async {
    if (_formKey.currentState.validate()) {
      final validator =
          effectives.any((element) => element.effectiveStatus == '');
      if (validator == true) {
        showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Atenção'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Informe o status de todos!'),
                  ],
                ),
              );
            });
      } else {
        send();
      }
    } else {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('Atenção'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Informe a quantidade de cafés da manhã e da tarde!'),
                ],
              ),
            );
          });
    }
  }
}
