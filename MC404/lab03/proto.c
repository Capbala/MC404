#include <stdlib.h> // For exit system call
#include <stdio.h>  // For printf and scanf

int string_to_integer(char *str)
{
  int num = 0; // Variable to hold the decimal number
  int i = 0;

  // Convert string to integer
  while (str[i] != '\0' && str[i] != '\n') {
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

  binary_str[2 + (32 - start_index)] = '\0'; // Newline character for write function
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
           hexadecimal_str[i] = 'A' + (hex_digit - 10); // Convert to character 'A'-'F'
       }
       num /= 16;
   }
   hexadecimal_str[10] = '\0'; // Newline character for write function
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
  hexadecimal_str[j] = '\0'; // Null-terminate the string
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

  temp[10] = '\0';
  // Copy back into original string
  for (int i = 0; i < 11; i++) {
      hexadecimal_str[i] = temp[i];
  }
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
  str[length] = '\0'; // Null-terminate the string
  for (int j = length - 1; j >= 0; j--) {
    str[j] = (num % 10) + '0'; // Extract the last digit and convert to character
    num /= 10;
  }
}

void hexadecimal_to_decimal(char *hexadecimal_str)
{
  int num = 0; // Variable to hold the decimal number
  int i = 2; // Start after "0x"

  // Convert hexadecimal to decimal
  while (hexadecimal_str[i] != '\0' && hexadecimal_str[i] != '\n') {
    num = num * 16;
    if (hexadecimal_str[i] >= '0' && hexadecimal_str[i] <= '9') {
      num += (hexadecimal_str[i] - '0');
    } else if (hexadecimal_str[i] >= 'A' && hexadecimal_str[i] <= 'F') {
      num += (hexadecimal_str[i] - 'A' + 10);
    }
    i++;
  }

  // Convert decimal number back to string
  char buffer[11]; // Buffer to hold the decimal string
  int_to_string(num, buffer);

  // Copy the result back to hexadecimal_str
  int j = 0;
  while (buffer[j] != '\0') {
    hexadecimal_str[j] = buffer[j];
    j++;
  }
  hexadecimal_str[j] = '\0'; // Null-terminate the string
}

void hexadecimal_to_binary(char *str, int *binary)
{
  int i = 0;
  int num = 0; // Variable to hold the decimal number

  // Convert hexadecimal string to decimal integer
  for (i = 2; str[i] != '\0' && str[i] != '\n'; i++) {
    num = num * 16;
    if (str[i] >= '0' && str[i] <= '9') {
      num += (str[i] - '0');
    } else if (str[i] >= 'A' && str[i] <= 'F') {
      num += (str[i] - 'A' + 10);
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
  while (str[i] != '\0' && str[i] != '\n') {
    i++;
  }
  return i;
}

void full_hex(char *hexadecimal_str)
{
  char temp[11];
  temp[0] = '0';
  temp[1] = 'x';
  temp[10] = '\0';
  int i = len(hexadecimal_str);
  int j = 9;
  for(int x = 2; x < 10; x++) {
    temp[x] = '0';
  }
  for (i = i - 1; i >= 2; i--, j--) {
    temp[j] = hexadecimal_str[i];
  }
  for (i = 0; i < 11; i++) {
    hexadecimal_str[i] = temp[i];
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
  scanf("%10s", str);
  
  switch(str[0])
  {
    case '0':
      // Hexadecimal input
      hexadecimal_to_binary(str, binary);
      binary_to_string(binary, binary_str);            // Hexadecimal to binary conversion
      printf("%s\n", binary_str);                      //

      char buffer[11];
      for (int i = 0; i < 11; i++) {
        buffer[i] = str[i];
      }
      hexadecimal_to_decimal(buffer);                     // Hexadecimal to decimal conversion
      printf("%s\n", buffer);                             // Print input string (hexadecimal)

      full_hex(str);                                // Full hexadecimal representation
      endian_swap(str);                                // Endianess swap
      hexadecimal_to_decimal(str);                     // Hexadecimal to decimal conversion
      printf("%s\n", str);                             //
      break;

    case '-':
      // Negative input
      break;

    default:
      // Decimal input
    {
      decimal_to_binary(str, binary);                  //
      binary_to_string(binary, binary_str);            // Decimal to binary conversion
      printf("%s\n", binary_str);                      //

      printf("%s\n", str);                             // Print input string (decimal)

      decimal_to_hexadecimal(str,hexadecimal_str);     //
      char buffer_hex [11];
      for (int i = 0; i < 11; i++) {
        buffer_hex[i] = hexadecimal_str[i];
      }
      hexadecimal_trim(buffer_hex);               // Binary to hexadecimal conversion
      printf("%s\n", buffer_hex);                 //


      endian_swap(hexadecimal_str);                    // Endianess swap
      hexadecimal_to_decimal(hexadecimal_str);         // Hexadecimal to decimal conversion
      printf("%s\n", hexadecimal_str);                 //
    }
    break;
  }
  return 0;
} // This program reads a string in hexadecimal, negative, or decimal format from standard input and converts it to binary, decimal,
  // hexadecimal and the input (decimal or hexadecimal) in hexadecimal representation with endianess swapped and converted to decimal.
  // It then writes the results to standard output.

