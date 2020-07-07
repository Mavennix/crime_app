import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_app/core/data-model/crimes.dm.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CrimeMap extends StatefulWidget {
  @override
  _CrimeMapState createState() => _CrimeMapState();
}

class _CrimeMapState extends State<CrimeMap> {
  Completer<GoogleMapController> _controller = Completer();
  Position position = Position();

  Map crimes = Map();

  Future<void> currentLocation() async {
    Position res = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      position = res;
    });
  }

  bool busy = false;
  final Firestore firestore = Firestore.instance;

  final _textController = TextEditingController();

  void submitCrime({String crimeDesc}) async {
    setState(() {
      busy = true;
    });
    try {
      await firestore.collection('crimes').add({
        'lng': position.longitude,
        'lat': position.latitude,
        'crime_desc': crimeDesc
      }).then((value) => getCrimes());
    } catch (e) {
      print(e);
    }
    setState(() {
      busy = false;
    });
  }

  getCrimes() async {
    try {
      List<LatLng> list = List();
      await firestore
          .collection('crimes')
          .getDocuments()
          .then((querySnapshot) async {
        querySnapshot.documents.forEach((result) {
          Crime crime = crimeFromJson(json.encode(result.data));
          crime.id = result.documentID;
          list.add(LatLng(crime.lat, crime.lng));
          print(crime.id);
        });
      }).then((value) => list.forEach((crimePosition) {
                setState(() {
                  crimes[crimePosition] = !crimes.containsKey(crimePosition)
                      ? (1)
                      : (crimes[crimePosition] + 1);
                });
              }));

      await _setMapPins();
    } catch (e) {
      print(e);
    }
  }

  void setUpMap() async {
    await currentLocation();
    await getCrimes();
    await _setMapPins();
  }

  Set<Marker> _markers = {};
  Future<BitmapDescriptor> getClusterMarker(
    int clusterSize,
  ) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()
      ..color = clusterSize < 5
          ? Colors.green
          : clusterSize == 5 || clusterSize < 20 ? Colors.orange : Colors.red;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final double radius = 80 / 2;
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );
    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        radius - textPainter.width / 2,
        radius - textPainter.height / 2,
      ),
    );
    final image = await pictureRecorder.endRecording().toImage(
          radius.toInt() * 2,
          radius.toInt() * 2,
        );
    final data = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  _setMapPins() async {
    await Future.forEach(crimes.keys, (element) async {
      _markers.add(Marker(
          markerId: MarkerId(element.toString()),
          position: element,
          icon: await getClusterMarker(crimes[element])));
    });

    setState(() {});
  }

  void _reportCrime() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(18.0),
            // heightFactor: 0.5,
            children: <Widget>[
              Text(
                'Crime Details',
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                // padding: EdgeInsets.all(18.0),
                child: Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
                        child: TextFormField(
                          controller: _textController,
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width / 28,
                          ),
                          autovalidate: true,
                          decoration: InputDecoration(
                              labelText: 'Note about crime',
                              helperText:
                                  'You can only submit crime in your current location'),
                          keyboardType: TextInputType.emailAddress,
                        )),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  padding: EdgeInsets.all(20.0),
                  color: Color(0xFF26263D),
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _textController.text = '';
                      setState(() {
                        _markers = {};
                        crimes = Map();
                      });
                    });
                    submitCrime(crimeDesc: _textController.text);
                  },
                  child: Text('Submit'),
                ),
              )
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    setUpMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: position.latitude == null || busy == true
          ? loadingWidget()
          : GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              initialCameraPosition: CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14.4746,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _reportCrime,
        label: Text('Report Crime'),
        backgroundColor: Color(0xFF26263D),
        // icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Widget loadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
