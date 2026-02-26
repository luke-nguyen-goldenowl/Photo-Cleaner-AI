enum AppRouteNames {
  splash(path: '/'),
  onBoarding(path: '/onboarding'),
  gettingStarted(path: '/getting-started'),
  home(path: '/home'),
  dev(path: '/dev'),
  account(path: '/account'),
  signIn(path: '/sign-in'),
  signUp(path: '/sign-up'),
  forgotPassword(path: '/forgot'),
  sample(path: '/sample'),
  sampleDetails(
    path: 'sample-details',
    paramName: 'id',
  ),
  profile(path: '/profile'),
  profileEdit(path: 'profile-edit'),
  settings(path: '/settings'),
  photo(path: '/photo'),
  photoDetail(path: '/photo-detail'),
  cleaner(path: '/cleaner'),
  selectImage(path: '/select-image'),
  resultRemoveBg(path: '/result-remove-bg'),
  removeBg(path: '/remove-bg'),
  friend(path: '/friend'),
  places(path: '/places'),
  ;

  const AppRouteNames({
    required this.path,
    this.paramName,
  });

  final String path;
  final String? paramName;

  String get name => path;

  String get subPath {
    if (path == '/') {
      return path;
    }
    return path.replaceFirst('/', '');
  }

  String get buildPathParam => '$path:$paramName';
  String get buildSubPathParam => '$subPath:$paramName';
}
