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

int string_to_integer(char *str)
{
  int num = 0; // Variable to hold the decimal number
  int i = 0;

  // Convert string to integer
  while (str[i] != '\n' && str[i] != '\n') {
    num = num * 10 + (str[i] - '0');
    i++;
  }
  return num;
}

void decimal_to_binary(char *str, int *binary)
{
  int num = string_to_integer(str); // Variable to hold the decimal number
  int i = 0;

  // Convert decimal to binary
  for (i = 31; i >= 0; i--) {
    binary[i] = num % 2;
    num /= 2;
  }
}

void binary_to_string(int binary[], char *binary_str)
{
  binary_str[0] = '0'; // 0b for binary representation
  binary_str[1] = 'b';
  int start_index = 0;
  while(binary[start_index] == 0 && start_index < 32) start_index++;

  for (int i = start_index, j = 2; i < 32; i++, j++) {
    binary_str[j] = binary[i] + '0'; // Convert binary digit to character
  }

  binary_str[2 + (32 - start_index)] = '\n'; // Newline character for write function
}

void decimal_to_hexadecimal(char *str, char *hexadecimal_str)
{
   int num = string_to_integer(str); // Variable to hold the decimal number
   int i;
   hexadecimal_str[0] = '0'; // 0x for hexadecimal representation
   hexadecimal_str[1] = 'x';

   for (i = 9; i >= 2; i--) 
   {
       int hex_digit = num % 16;
       if (hex_digit < 10) {
           hexadecimal_str[i] = '0' + hex_digit; // Convert to character '0'-'9'
       } else {
           hexadecimal_str[i] = 'a' + (hex_digit - 10); // Convert to character 'A'-'F'
       }
       num /= 16;
   }
   hexadecimal_str[10] = '\n'; // Newline character for write function
}

void hexadecimal_trim(char *hexadecimal_str)
{
  int start_index = 2; // Start after "0x"
  while (hexadecimal_str[start_index] == '0' && start_index < 10) {
    start_index++;
  }

  // Shift the string to remove leading zeros
  int j = 2;
  for (int i = start_index; i < 11; i++, j++) {
    hexadecimal_str[j] = hexadecimal_str[i];
  }
  hexadecimal_str[j] = '\n'; // Null-terminate the string
}

void endian_swap(char *hexadecimal_str)
{
  char temp[11]; // "0x" + 8 hex digits + null terminator
  temp[0] = '0';
  temp[1] = 'x';

  // Copy bytes in reverse order (2 chars = 1 byte)
  temp[2] = hexadecimal_str[8];
  temp[3] = hexadecimal_str[9];
  temp[4] = hexadecimal_str[6];
  temp[5] = hexadecimal_str[7];
  temp[6] = hexadecimal_str[4];
  temp[7] = hexadecimal_str[5];
  temp[8] = hexadecimal_str[2];
  temp[9] = hexadecimal_str[3];

  temp[10] = '\n';
  // Copy back into original string
  for (int i = 0; i < 11; i++) {
      hexadecimal_str[i] = temp[i];
  }
}

void uint_to_string(unsigned int num, char *str)
{
  unsigned int temp = num;
  int length = 0;

  // Determine the length of the number
  do {
    length++;
    temp /= 10;
  } while (temp != 0);

  // Fill the buffer from the end
  str[length] = '\n'; // Null-terminate the string
  for (int j = length - 1; j >= 0; j--) {
    str[j] = (num % 10) + '0'; // Extract the last digit and convert to character
    num /= 10;
  }
}

void hexadecimal_to_decimal(char *hexadecimal_str)
{
  unsigned int num = 0; // Variable to hold the decimal number
  int i = 2; // Start after "0x"

  // Convert hexadecimal to decimal
  while (hexadecimal_str[i] != '\n' && hexadecimal_str[i] != '\n') {
    num = num * 16;
    if (hexadecimal_str[i] >= '0' && hexadecimal_str[i] <= '9') {
      num += (hexadecimal_str[i] - '0');
    } else if (hexadecimal_str[i] >= 'a' && hexadecimal_str[i] <= 'f') {
      num += (hexadecimal_str[i] - 'a' + 10);
    }
    i++;
  }

  // Convert decimal number back to string
  char buffer[11]; // Buffer to hold the decimal string
  uint_to_string(num, buffer);

  // Copy the result back to hexadecimal_str
  int j = 0;
  while (buffer[j] != '\n') {
    hexadecimal_str[j] = buffer[j];
    j++;
  }
  hexadecimal_str[j] = '\n'; // Null-terminate the string
}

void hexadecimal_to_binary(char *str, int *binary)
{
  int i = 0;
  unsigned int num = 0; // Variable to hold the decimal number

  // Convert hexadecimal string to decimal integer
  for (i = 2; str[i] != '\n' && str[i] != '\n'; i++) {
    num = num * 16;
    if (str[i] >= '0' && str[i] <= '9') {
      num += (str[i] - '0');
    } else if (str[i] >= 'a' && str[i] <= 'f') {
      num += (str[i] - 'a' + 10);
    }
  }

  // Convert decimal integer to binary array
  for (i = 31; i >= 0; i--) {
    binary[i] = num % 2;
    num /= 2;
  }
}

int len(char *str) {
  int i = 0;
  while (str[i] != '\n' && str[i] != '\0') {
    i++;
  }
  return i+1;
}

void full_hex(char *hexadecimal_str)
{
  char temp[11];
  temp[0] = '0';
  temp[1] = 'x';
  temp[10] = '\n';
  int src = len(hexadecimal_str) - 2;   // last hex digit (skip '\n')
  int dst = 9;
  while (src >= 2 && dst >= 2) {
    temp[dst--] = hexadecimal_str[src--];
  }

  for (int i = 0; i < 11; i++) hexadecimal_str[i] = temp[i];
}

void twos_complement(int *binary)
{
  // Invert bits
  for (int i = 0; i < 32; i++) {
    binary[i] = 1 - binary[i];
  }

  // Add 1 to the least significant bit
  for (int i = 31; i >= 0; i--) {
    if (binary[i] == 0) {
      binary[i] = 1;
      break;
    } else {
      binary[i] = 0;
    }
  }
}

void invert_hex(char *hexadecimal_str)
{
  int start_index = 2; // Start after "0x"
  int end_index = len(hexadecimal_str) - 2;

  // Swap characters to reverse the string
  while (start_index < end_index) {
    char temp = hexadecimal_str[start_index];
    hexadecimal_str[start_index] = hexadecimal_str[end_index];
    hexadecimal_str[end_index] = temp;
    start_index++;
    end_index--;
  }
}

void binary_to_hexadecimal(int *binary, char *hexadecimal_str)
{
  hexadecimal_str[0] = '0'; // 0x for hexadecimal representation
  hexadecimal_str[1] = 'x';

  for (int i = 0; i < 8; i++) {
    int hex_digit = 0;
    for (int j = 0; j < 4; j++) {
      hex_digit = (hex_digit << 1) | binary[i * 4 + j]; // Combine 4 bits into a hex digit
    }
    if (hex_digit < 10) {
      hexadecimal_str[9 - i] = '0' + hex_digit; // Convert to character '0'-'9'
    } else {
      hexadecimal_str[9 - i] = 'a' + (hex_digit - 10); // Convert to character 'A'-'F'
    }
  }
  hexadecimal_str[10] = '\n'; // Null-terminate the string
  invert_hex(hexadecimal_str);
}

void int_to_string(int num, char *str)
{
  int temp = num;
  int length = 0;

  // Determine the length of the number
  do {
    length++;
    temp /= 10;
  } while (temp != 0);

  // Fill the buffer from the end
  str[length] = '\n'; // Null-terminate the string
  for (int j = length - 1; j >= 0; j--) {
    str[j] = (num % 10) + '0'; // Extract the last digit and convert to character
    num /= 10;
  }
}

void full_binary(int *binary, char *binary_str)
{
  binary_str[0] = '0'; // 0b for binary representation
  binary_str[1] = 'b';

  for (int i = 0; i < 32; i++) {
    binary_str[i + 2] = binary[i] + '0'; // Convert binary digit to character
  }

  binary_str[34] = '\0'; // Null-terminate the string
}

void safe_write(int fd, char *src)
{
    // Find the position of '\n'
    int i = 0;
    while (src[i] != '\n' && src[i] != '\0') {
        i++;
    }

    if (src[i] == '\n') {
        // Write including the newline
        write(fd, src, i+1);
    } else {
        // If there was no newline, add one
        char buf[32];
        for (int j = 0; j < i; j++) buf[j] = src[j];
        buf[i] = '\n';
        buf[i+1] = '\0';
        write(fd, buf, i+1);
    }
}

unsigned int binary_to_uint(int *binary)
{
  unsigned int num = 0;
  for (int i = 0; i < 32; i++) {
    num = (num << 1) | binary[i];
  }
  return num;
}

void hex_decimal_output(int *binary, char *binary_str, char *buffer)
{
  if (binary_str[2] == '1') {
    // Negative number
    twos_complement(binary);
    unsigned int magnitude = binary_to_uint(binary);

    char magnitude_str[11];
    uint_to_string(magnitude, magnitude_str);
    // Prepend the '-' sign for the final output
    char signed_buffer[12];
    signed_buffer[0] = '-';
    int i = 0;
    while(magnitude_str[i] != '\n' && magnitude_str[i] != '\0') {
      signed_buffer[i+1] = magnitude_str[i];
      i++;
      }
    signed_buffer[i+1] = '\n';

    safe_write(STDOUT_FD, signed_buffer);
  } else {
    // The number is positive, print the original unsigned conversion
    safe_write(STDOUT_FD, buffer);
  }
}

int main()
{
  //since input are max 10 digits + \n
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
      hexadecimal_to_binary(str, binary);              //
      binary_to_string(binary, binary_str);            // Hexadecimal to binary conversion
      //printf("%s\n", binary_str);                    //
      safe_write(STDOUT_FD, binary_str);                //

      char buffer[11];
      for (int i = 0; i < 11; i++) {
        buffer[i] = str[i];
      }
      hexadecimal_to_decimal(buffer);                  // Hexadecimal to decimal conversion
      full_binary(binary, binary_str);                 // check the MSD for negative value
      hex_decimal_output(binary, binary_str, buffer);

      //printf("%s\n", str);                           // Print input string (hexadecimal)
      safe_write(STDOUT_FD, str);                 //

      full_hex(str);                                   // Full hexadecimal representation
      endian_swap(str);                                // Endianess swap
      hexadecimal_to_decimal(str);                     // Hexadecimal to decimal conversion
      //printf("%s\n", str);                           //
      safe_write(STDOUT_FD, str);                 //
      break;

    case '-':
      // Negative input
      str[0] = '0'; // Replace '-' with '0' for conversion
      decimal_to_binary(str, binary);                  //
      twos_complement(binary);                         // Two's complement for negative numbers
      binary_to_string(binary, binary_str);            // Decimal to binary conversion
      //printf("%s\n", binary_str);                    //
      safe_write(STDOUT_FD, binary_str);                //

      str[0] = '-'; // Restore '-' for printing
      //printf("%s\n", str);                           // Print input string (negative decimal)
      safe_write(STDOUT_FD, str);                 //
      
      binary_to_hexadecimal(binary, hexadecimal_str);  // Binary to hexadecimal conversion
      //printf("%s\n", hexadecimal_str);               //
      safe_write(STDOUT_FD, hexadecimal_str);           //

      full_hex(hexadecimal_str);                      // Full hexadecimal representation
      endian_swap(hexadecimal_str);                   // Endianess swap
      hexadecimal_to_decimal(hexadecimal_str);        // Hexadecimal to decimal conversion
      //printf("%s\n", hexadecimal_str);              //
      safe_write(STDOUT_FD, hexadecimal_str);    

      break;

    default:
      // Decimal input
    {
      decimal_to_binary(str, binary);                  //
      binary_to_string(binary, binary_str);            // Decimal to binary conversion
      //printf("%s\n", binary_str);                    //
      safe_write(STDOUT_FD, binary_str);                //

      //printf("%s\n", str);                           // Print input string (decimal)
      safe_write(STDOUT_FD, str);                        //

      decimal_to_hexadecimal(str,hexadecimal_str);     //
      char buffer_hex [11];                            //  
      for (int i = 0; i < 11; i++) {                   //
        buffer_hex[i] = hexadecimal_str[i];            //
      }
      hexadecimal_trim(buffer_hex);                    // Binary to hexadecimal conversion
      //printf("%s\n", buffer_hex);                    //
      safe_write(STDOUT_FD, buffer_hex);                //

      endian_swap(hexadecimal_str);                    // Endianess swap
      hexadecimal_to_decimal(hexadecimal_str);         // Hexadecimal to decimal conversion
      //printf("%s\n", hexadecimal_str);               //
      safe_write(STDOUT_FD, hexadecimal_str);
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