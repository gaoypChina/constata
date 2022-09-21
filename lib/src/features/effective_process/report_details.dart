import 'package:flutter/material.dart';

class ReportDetails extends StatefulWidget {
  final Map reportDetail;

  ReportDetails({Key key, this.reportDetail}) : super(key: key);

  @override
  _ReportDetailsState createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  @override
  Widget build(BuildContext context) {
    List efetivo = widget.reportDetail['data']['tb01_cp011'];
    TextStyle style = TextStyle(color: Colors.black, fontSize: 16);
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do efetivo'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ListTile(
                title: RichText(
                    text: TextSpan(text: '', style: style, children: [
                  TextSpan(
                      text: 'Cod: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: widget.reportDetail['data']['h0_cp003'].toString())
                ])),
              ),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                TextSpan(
                    text: 'Data: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp008']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                TextSpan(
                    text: 'Obra: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: '${widget.reportDetail['data']['h0_cp013']['name']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                TextSpan(
                    text: 'Local de Negócio: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp006']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                TextSpan(
                    text: 'Segmento: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp015']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                TextSpan(
                    text: 'Responsável: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp009']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                TextSpan(
                    text: 'Qte Cafés da manhã: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp010']}')
              ]))),
              ListTile(
                  title: RichText(
                      text: TextSpan(text: '', style: style, children: [
                TextSpan(
                    text: 'Qte Cafés da tarde: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${widget.reportDetail['data']['h0_cp011']}')
              ]))),
              Divider(),
              Container(
                child: Center(
                  child: Text('Lista de efetivo'),
                ),
              ),
              Divider(color: Colors.transparent),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: efetivo.isEmpty ? 0 : efetivo.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        trailing: Text('${efetivo[index]['tp_cp015']}'),
                        title: Text('${efetivo[index]['tp_cp013']}'),
                        subtitle: Text('RG: ${efetivo[index]['tp_cp012']}'),
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}
