import 'package:constata_0_0_2/src/features/measurement/measurement_card.dart';
import 'package:flutter/material.dart';

class MeasurementDetails extends StatefulWidget {
  Map measurement;

  MeasurementDetails({Key key, this.measurement}) : super(key: key);
  @override
  _MeasurementDetailsState createState() => _MeasurementDetailsState();
}

class _MeasurementDetailsState extends State<MeasurementDetails> {
  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(color: Colors.black, fontSize: 16);
    TextStyle titleStyle = TextStyle(fontWeight: FontWeight.bold);
    List measurements = widget.measurement['data']['tb01_cp050'];
    return Scaffold(
        appBar: AppBar(
          title: Text('Detalhes da medição'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: [
                ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                    TextSpan(text: 'Cod: ', style: titleStyle),
                    TextSpan(text: widget.measurement['data']['h0_cp003'])
                  ])),
                ),
                ListTile(
                    title: RichText(
                        text: TextSpan(text: '', style: style, children: [
                  TextSpan(text: 'Data: ', style: titleStyle),
                  TextSpan(text: widget.measurement['data']['h0_cp008'])
                ]))),
                ListTile(
                    title: RichText(
                        text: TextSpan(text: '', style: style, children: [
                  TextSpan(text: 'Obra: ', style: titleStyle),
                  TextSpan(text: widget.measurement['data']['h0_cp007']['name'])
                ]))),
                ListTile(
                    title: RichText(
                        text: TextSpan(text: '', style: style, children: [
                  TextSpan(text: 'Local de Negocio: ', style: titleStyle),
                  TextSpan(text: widget.measurement['data']['h0_cp006'])
                ]))),
                ListTile(
                    title: RichText(
                        text: TextSpan(text: '', style: style, children: [
                  TextSpan(text: 'Apontador: ', style: titleStyle),
                  TextSpan(text: widget.measurement['data']['h0_cp009'])
                ]))),
                ListTile(
                    title: RichText(
                        text: TextSpan(text: '', style: style, children: [
                  TextSpan(text: 'Segmento: ', style: titleStyle),
                  TextSpan(text: widget.measurement['data']['h0_cp013'])
                ]))),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: measurements.length,
                    itemBuilder: (BuildContext context, int index) {
                      print(measurements[index]);
                      return MeasurementCard(
                        jsonBody: measurements[index],
                        callback: () {},
                        editing: false,
                      );
                    })
              ],
            ),
          ),
        ));
  }
}
