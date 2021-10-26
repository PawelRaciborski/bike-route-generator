import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

void launchURL(String url) async => await canLaunch(url)
    ? await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      )
    : throw 'Could not launch $url';

String generateGoogleMapsUrl(List<Coords> coords) {
  final buffer = new StringBuffer();

  buffer
    ..write("https://www.google.pl/maps/dir/")
    ..write("'${coords[0].latitude},${coords[0].longitude}'/");

  coords.sublist(1).forEach((element) {
    buffer.write("${element.latitude},${element.longitude}/");
  });

  return buffer.toString();
}
