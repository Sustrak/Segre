#define SIZE 128
#define DISP 7

int main() {
    int *a = (int *) 0x12000;
    int *b = a + SIZE*SIZE;
    int *c = b + SIZE*SIZE;
    
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            c[i+(j<<DISP)] = 0;
            for (int k = 0; k < SIZE; k++) {
                c[i+(j<<DISP)] = c[i+(j<<DISP)] + a[i+(k<<DISP)] * b[k+(j<<DISP)];
            }
        }
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
}
