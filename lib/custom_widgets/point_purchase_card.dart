import 'package:mangaturn/models/user_models/point_purchase_model.dart';
import 'package:flutter/material.dart';

Widget PointPurchaseCard(
    BuildContext context, PointPurchaseModel history, int index) {
  var date = DateTime.fromMicrosecondsSinceEpoch(
      history.requestedDateInMilliSeconds * 1000);
  var requestDate = date.day.toString() +
      " - " +
      date.month.toString() +
      " - " +
      date.year.toString();

  return ExpansionTile(
    leading: CircleAvatar(
      backgroundColor: Colors.indigo,
      child: Text(index.toString()),
    ),
    title: history.point == null
        ? Text('Your request is processing..')
        : Text(
            "Points - " + history.point.toString(),
          ),
    subtitle: Text(
      'Purchase Status - ' + history.status,
      style: TextStyle(
          color: history.status == 'REJECT' ? Colors.red : Colors.indigo),
    ),
    children: [
      ListTile(
        title: Text('Your Remark'),
        subtitle: Text(history.remark == null ? 'No remark' : history.remark!),
        trailing: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Hero(
                      tag: history.id,
                      child: Image.network(history.receiptUrl)),
                ));
          },
          child: Container(
            width: 100,
            child: Hero(
              tag: history.id,
              child: Image.network(
                history.receiptUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      ListTile(
        leading: Icon(Icons.person),
        title: Text('Admin Reply'),
        subtitle: history.adminRemark == null
            ? Text('Admin will confirm your request within 24 hours.')
            : Text(history.adminRemark!),
      ),
      ListTile(
        leading: Icon(Icons.calendar_today),
        title: Text('Date'),
        subtitle: Text(requestDate),
      ),
    ],
  );
}
