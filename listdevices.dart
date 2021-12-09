import 'dart:ffi';
import 'package:ffi/ffi.dart';

late int Function(Pointer<Int32> version, Pointer<Void> authCallBack) sane_init;
typedef sane_init_native_t = Int32 Function(
    Pointer<Int32> version, Pointer<Void> authCallBack);

late void Function() sane_exit;
typedef sane_exit_native_t = Void Function();

late int Function(
        Pointer<Pointer<Pointer<SANE_Device>>> device_list, int local_only)
    sane_get_devices;
typedef sane_get_devices_native_t = Int32 Function(
    Pointer<Pointer<Pointer<SANE_Device>>> device_list, Int32 local_only);

class SANE_Device extends Struct {
  external Pointer<Utf8> name;
  external Pointer<Utf8> vendor;
  external Pointer<Utf8> model;
  external Pointer<Utf8> type;
}

void main() {
  final dlopen = DynamicLibrary.process().lookupFunction<
      Pointer<Void> Function(Pointer<Utf8>, Int32),
      Pointer<Void> Function(Pointer<Utf8>, int)>('dlopen');
  final dlsym = DynamicLibrary.process().lookupFunction<
      Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>),
      Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>)>('dlsym');

  const RTLD_LAZY = 0x00001;
  final libsane = dlopen(
    "libsane.so".toNativeUtf8(), // note: toNativeUtf8 leaks memory
    RTLD_LAZY,
  );

  sane_init = dlsym(libsane, 'sane_init'.toNativeUtf8())
      .cast<NativeFunction<sane_init_native_t>>()
      .asFunction();
  sane_exit = dlsym(libsane, 'sane_exit'.toNativeUtf8())
      .cast<NativeFunction<sane_exit_native_t>>()
      .asFunction();
  sane_get_devices = dlsym(libsane, 'sane_get_devices'.toNativeUtf8())
      .cast<NativeFunction<sane_get_devices_native_t>>()
      .asFunction();

  // Test code, error handling omitted
  Pointer<Int32> vc = calloc();
  int res = sane_init(vc, nullptr);
  calloc.free(vc);

  Pointer<Pointer<Pointer<SANE_Device>>> device_list = calloc();
  res = sane_get_devices(device_list, 0);

  for (int i = 0; device_list.value[i] != nullptr; i++) {
    print(device_list.value[i].ref.name.toDartString());
  }

  sane_exit();
  calloc.free(device_list);
}
