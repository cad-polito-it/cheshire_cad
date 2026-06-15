extern long alu_lfsr_test(unsigned long n, unsigned long seed);

int main() {
    long checksum;
    checksum = alu_lfsr_test(10, 1);  // seed != 0
    return 0;
}