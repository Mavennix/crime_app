class WelcomeSlide{
  String title;
  String image;

  WelcomeSlide({
    this.title,
    this.image,
  });
}

List<WelcomeSlide> welcomeItems = [
  WelcomeSlide(title: 'Be on the look out!', image: 'assets/images/welcome/spot.png'),
  WelcomeSlide(title: 'Report any criminal activity.', image: 'assets/images/welcome/report.png'),
  WelcomeSlide(title: 'Make the world a safer place.', image: 'assets/images/welcome/save_world.png'),
];
