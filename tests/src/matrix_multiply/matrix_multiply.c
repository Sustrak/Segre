int main() {
    int *a = (int *) 0xA000;
    int *b = a + 128*128;
    int *c = b + 128*128;

    for (int i = 0; i < 128; i++) {
        for (int j = 0; j < 128; j++) {
            c[i+(j<<7)] = 0;
            for (int k = 0; k < 128; k++) {
                c[i+(j<<7)] = c[i+(j<<7)] + a[i+(k<<7)] * b[k+(j<<7)];
            }
        }
    }
}
