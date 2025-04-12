## Custom MBR Example

*This is an example of a custom MBR (Master Boot Record) for educational purposes only.*

## Features
- Reading from disk
- Outputting text to the screen using BIOS interrupts
- Deleting from disk (writing zeros)
- Hashing the password and storing it in protected access

## Compilation
To compile the MBR code for a 16-bit version using NASM, use the following command:

to build hash.s file it is enough to enter it into the terminal (linux, since the functions of output to the terminal are used for linux)

`nasm -f elf64 hash.s && ld -o hash hash.o`

it will work since all register sizes were taken into account during programming.

![Pasted image 20250412235634](https://github.com/user-attachments/assets/e2a6c8d6-7236-47aa-8eba-c96e396f9515)

This is how the output looks and, accordingly, the start of the program to generate the hash (it is necessary, because in the program mbr password is not stored openly, and with the help of hash function input is converted to another combination and there is already a comparison with the hash)

initially in mbr is a hash for the entered combination 

12345

![Pasted image 20250412235850](https://github.com/user-attachments/assets/3cb34f5a-03dc-4f28-9212-f0b44d95207f)

`nasm -f bin -o mbr.bin mbr.s`

![Pasted image 20250413001327](https://github.com/user-attachments/assets/eb4ba949-5110-44ad-a12c-b96fbb394c69)

since this is a tutorial application, *you need to fix the size of hash function or string-to-number function or something else to make the code the right size and then the error will go away*

`mbr.s:146: error: negative argument supplied to DUP`

## Disclaimer

This MBR bootloader is for **educational and demonstration purposes only**.
Using or modifying this code for malicious purposes is **strongly discouraged**
and may be **illegal** under applicable laws. The author takes **no responsibility**
for any damage or data loss caused by improper use
