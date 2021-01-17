int main(void) {
    int sum = 0;
    int *a = (int*) 0xA000;
    for (int i = 0; i < 128; i++) {
        sum += a[i];
    }
    __asm__(
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "nop \n"
        "csrw 0xfff, x0 \n"
    );
    return sum;
}
