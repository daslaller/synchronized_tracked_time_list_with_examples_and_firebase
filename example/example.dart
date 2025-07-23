import 'package:synchronized_tracked_time_list/src/cloud_provider.dart';

void main() {
  // Clean up
  AppWriteProvider(
    region: AppWriteRegions.Frankfurt,
    projectId: '687fc3560026d60bae50',
    key:
        'standard_a3202805cf6453f19964b1a0ba2facf0856c90f166a6cac18eb6ba84fa79166911fdf2d12047c8f218571d011369540da80869e1e8057045f6ca3b343782bbe30668d2a4943727ab84f01ded0e5d9aed15e8e703d54c1a431d564a49d904ddf4afa3aa6e5969f7d0ae7ef815bd7f109c441a5d64777adbb3f32f45630721a773',
  );
  AppWriteProvider.instance?.connected.then((value) {
    print('Connected: $value');
  });
}
