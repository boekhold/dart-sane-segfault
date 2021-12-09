#include <stdio.h>
#include <sane/sane.h>

int main(int argc, char **argv) {
    const SANE_Device **deviceList;

    int vc;
    SANE_Status status;

    status = sane_init(&vc, NULL);
    status = sane_get_devices(&deviceList, 0);
    for (int i = 0 ; deviceList[i] != NULL ; i++) {
      printf("%s\n", deviceList[i]->name);
    }
    sane_exit();
}
