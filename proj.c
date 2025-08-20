int read(int __fd, const void *__buf, int __n){
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

#define STDIN_FD  0
#define STDOUT_FD 1

int decimal_to_binary(char *str, int *binary)
{
  int num = 0; // Variable to hold the decimal number
  int i = 0;

  // Convert string to integer
  while (str[i] != '\0' && str[i] != '\n') {
    num = num * 10 + (str[i] - '0');
    i++;
  }

  // Convert decimal to binary
  for (i = 31; i >= 0; i--) {
    binary[i] = num % 2;
    num /= 2;
  }
  return 0;
}

void binary_to_string(int binary[], char *binary_str)
{
  binary_str[0] = '0'; // First character for binary representation
  binary_str[1] = 'b'; // Second character for binary representation

  for (int i = 0; i < 34; i++) {
    binary_str[i + 2] = binary[i] + '0'; // Convert binary digit to character
  }
  binary_str[34] = '\n'; // Null-terminate the string
}

void decimal_to_hexadecimal(char *str, char *hexadecimal_str)
{
  int num = 0; // Variable to hold the decimal number
  int i = 0;

  // Convert string to integer
  while (str[i] != '\0' && str[i] != '\n') {
    num = num * 10 + (str[i] - '0');
    i++;
  }

  // Convert decimal to hexadecimal
  hexadecimal_str[0] = '0'; // First character for hexadecimal representation
  hexadecimal_str[1] = 'x'; // Second character for hexadecimal representation

  for (i = 9; i >= 2; i--) {
  return 0;

}

int main()
{
  /* Read up to 20 bytes from the standard input into the str buffer */
  char str[11];
  char binary_str[35]; // 0b + 32 bits + null terminator
  int binary[32];
  char hexadecimal_str[11]; // 0x + 8 hex digits + null terminator

  /* Write n bytes from the str buffer to the standard output */
  int n = read(STDIN_FD, str, 11);
  
  switch(str[0])
  {
    case '0':
      // Hexadecimal input
      break;

    case '-':
      // Negative input
      break;

    default:
      // Decimal input
    {
      decimal_to_binary(str, binary);                  //
      binary_to_string(binary, binary_str);            // Decimal to binary conversion
      write(STDOUT_FD, binary_str, 35);                //

      decimal_to_hexadecimal(str,hexadecimal_str);   // Binary to hexadecimal conversion
      write(STDOUT_FD, hexadecimal_str, 35);           //


    }
    break;
  }
  return 0;
} // This program reads a string in hexadecimal, negative, or decimal format from standard input and converts it to binary, decimal,
  // hexadecimal and the input (decimal or hexadecimal) in hexadecimal representation with endianess swapped and converted to decimal.
  // It then writes the results to standard output.
void _start()
{
  int ret_code = main();
  exit(ret_code);
}
