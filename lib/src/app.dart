import 'package:bot_toast/bot_toast.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/logic/enhance_image_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/logic/make_video_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/remove_bg/logic/remove_bg_bloc.dart';
import 'package:myapp/src/features/dashboard/photo/logic/photo_bloc.dart';
import 'package:myapp/src/features/dashboard/place/logic/place_bloc.dart';
import 'package:myapp/src/features/settings/logic/setting_bloc.dart';
import 'package:myapp/src/router/router.dart';
import 'package:myapp/src/services/network-connection/internet_connection_cubit.dart';
import 'package:myapp/src/theme/screen.dart';
import 'package:myapp/src/theme/themes.dart';
import 'package:myapp/src/localization/localization_utils.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    AppScreens.init(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingBloc()),
        BlocProvider(create: (_) => GetIt.I<AccountBloc>()),
        BlocProvider(create: (_) => InternetConnectionCubit()),
        BlocProvider(create: (_) => PhotoViewBloc()),
        BlocProvider(create: (_) => PlaceBloc()),
        BlocProvider(create: (_) => RemoveBgBloc()),
        BlocProvider(create: (_) => MakeVideoBloc()),
        BlocProvider(create: (_) => EnhanceImageBloc()),
      ],
      child: BlocBuilder<SettingBloc, SettingState>(builder: (context, state) {
        return MaterialApp.router(
          localizationsDelegates: S.localizationsDelegates,
          supportedLocales: S.supportedLocales,
          onGenerateTitle: (context) => S.of(context).common_appTitle,
          debugShowCheckedModeBanner: false,
          //builder: BotToastInit(),
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.themeMode,
          routerConfig: GetIt.I<AppRouter>().router,
          //locale: DevicePreview.locale(context),
          builder: (context, child) {
            final deviceBuilt = DevicePreview.appBuilder(context, child);
            return BotToastInit()(context, deviceBuilt);
          },
        );
      }),
    );
  }
}
