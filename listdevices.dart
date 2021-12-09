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
  // Boiler-plate for the bindings
  late DynamicLibrary sane;
  sane = DynamicLibrary.open('libsane.so');

  sane_init =
      sane.lookup<NativeFunction<sane_init_native_t>>('sane_init').asFunction();
  sane_exit =
      sane.lookup<NativeFunction<sane_exit_native_t>>('sane_exit').asFunction();
  sane_get_devices = sane
      .lookup<NativeFunction<sane_get_devices_native_t>>('sane_get_devices')
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
