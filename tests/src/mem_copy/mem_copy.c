int main () {
    int* a = (int *) 0xA000;
    int* b = a + 128;
    for (int i = 0; i < 128; i++) a[i] = 5;
    for (int i = 0; i < 128; i++) b[i] = a[i];
    __asm__(
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "csrw 0xfff, x0 \n"
    );
}
