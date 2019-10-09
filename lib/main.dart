import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gpx/gpx.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Show GPX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Show GPX App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Polyline> _traceGPX = [];
  MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _addGpx() async {
    final filePath = await FilePicker.getFilePath(type: FileType.ANY);
    if (filePath != null) {
      try {
        final file = File(filePath);
        final contents = await file.readAsString();
        var xmlGpx = GpxReader().fromString(contents);
        print(xmlGpx);
        //center
        final first = xmlGpx.trks.first.trksegs.first.trkpts.first;
        _mapController.move(LatLng(first.lat, first.lon), 13.0);

        //trace gpx
        for (var trk in xmlGpx.trks) {
          for (var trkseg in trk.trksegs) {
            List<LatLng> line = [];
            for (var pt in trkseg.trkpts) {
              line.add(LatLng(pt.lat, pt.lon));
            }
            _traceGPX.add(Polyline(points: line, color: Colors.red));
          }
        }
      } catch (e) {
        print('error read gpx: ' + e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(51.5, -0.09),
            zoom: 13.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://api.tiles.mapbox.com/v4/"
                  "{id}/{z}/{x}/{y}@2x.png?access_token={accessToken}",
              additionalOptions: {
                'accessToken': '<key here>',
                'id': 'mapbox.streets',
              },
            ),
            PolylineLayerOptions(polylines: _traceGPX)
          ],
          mapController: _mapController,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGpx,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
