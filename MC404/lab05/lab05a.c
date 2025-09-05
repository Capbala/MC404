#define MASK_3_BITS  0x7u
#define MASK_5_BITS  0x1Fu
#define MASK_8_BITS  0xFFu
#define MASK_11_BITS 0x7FFu 

#define STDIN_FD  0
#define STDOUT_FD 1

int read(int __fd, const void *__buf, int __n)
{
    int ret_val;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read code (63) \n"
    "ecall               # invoke syscall \n"
    "mv %0, a0           # move return value to ret_val\n"
    : "=r"(ret_val)  // Output list
    : "r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return ret_val;
}

void write(int __fd, const void *__buf, int __n)
{
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
}

void exit(int code)
{
  __asm__ __volatile__(
    "mv a0, %0           # return code\n"
    "li a7, 93           # syscall exit (93) \n"
    "ecall"
    :   // Output list
    :"r"(code)    // Input list
    : "a0", "a7"
  );
}

void hex_code(int val)
{
    char hex[11];
    unsigned int uval = (unsigned int) val, aux;

    hex[0] = '0';
    hex[1] = 'x';
    hex[10] = '\n';

    for (int i = 9; i > 1; i--){
        aux = uval % 16;
        if (aux >= 10)
            hex[i] = aux - 10 + 'A';
        else
            hex[i] = aux + '0';
        uval = uval / 16;
    }
    write(STDOUT_FD, hex, 11);
}

void convert_ints(char *buffer, int *a1, int *a2, int *a3, int *a4, int *a5) 
{
    int sign;
    char *ptr = buffer;

    // Convert a1
    sign = (*ptr == '-') ? -1 : 1;
    if (*ptr == '-' || *ptr == '+') ptr++;
    *a1 = 0;
    while (*ptr >= '0' && *ptr <= '9') {
        *a1 = *a1 * 10 + (*ptr - '0');
        ptr++;
    }
    *a1 *= sign;
    if (*ptr == ' ') ptr++;

    // Convert a2
    sign = (*ptr == '-') ? -1 : 1;
    if (*ptr == '-' || *ptr == '+') ptr++;
    *a2 = 0;
    while (*ptr >= '0' && *ptr <= '9') {
        *a2 = *a2 * 10 + (*ptr - '0');
        ptr++;
    }
    *a2 *= sign;
    if (*ptr == ' ') ptr++;

    // Convert a3
    sign = (*ptr == '-') ? -1 : 1;
    if (*ptr == '-' || *ptr == '+') ptr++;
    *a3 = 0;
    while (*ptr >= '0' && *ptr <= '9') {
        *a3 = *a3 * 10 + (*ptr - '0');
        ptr++;
    }
    *a3 *= sign;
    if (*ptr == ' ') ptr++;

    // Convert a4
    sign = (*ptr == '-') ? -1 : 1;
    if (*ptr == '-' || *ptr == '+') ptr++;
    *a4 = 0;
    while (*ptr >= '0' && *ptr <= '9') {
        *a4 = *a4 * 10 + (*ptr - '0');
        ptr++;
    }
    *a4 *= sign;
    if (*ptr == ' ') ptr++;

    // Convert a5
    sign = (*ptr == '-') ? -1 : 1;
    if (*ptr == '-' || *ptr == '+') ptr++;
    *a5 = 0;
    while (*ptr >= '0' && *ptr <= '9') {
        *a5 = *a5 * 10 + (*ptr - '0');
        ptr++;
    }
    *a5 *= sign;
    
}

int pack(int a1, int a2, int a3, int a4, int a5)
{
    // mask widths: a1=3 bits, a2=8 bits, a3=5 bits, a4=5 bits, a5=11 bits
    int a1b = ((int)a1 & MASK_3_BITS) << 0;
    int a2b = ((int)a2 & MASK_8_BITS) << 3;
    int a3b = ((int)a3 & MASK_5_BITS) << 11;
    int a4b = ((int)a4 & MASK_5_BITS) << 16;
    int a5b = ((int)a5 & MASK_11_BITS) << 21;

    return a5b | a4b | a3b | a2b | a1b;
}

int main()
{
    int a5;
    int a4;
    int a3;
    int a2;
    int a1;
    char buffer[31];

    read(STDIN_FD, buffer, 31); // input format "SDDDD SDDDD SDDDD SDDDD SDDDD\n" S = sign D = digit

    convert_ints(buffer, &a1, &a2, &a3, &a4, &a5);
    int packed = pack(a1, a2, a3, a4, a5);
    hex_code(packed);
    
    return 0;
}

void _start()
{
  int ret_code = main();
  exit(ret_code);
}
