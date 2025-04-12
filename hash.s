section .data:
    prompt1 db "Enter a decimal number (you can also enter letters, but that's a secret: ", 0  ; ����������� ��� �����
    prompt2 db "Here, your hash is a baller hacker: ", 0  
    prompt3 db 10

section .bss
    password_num resb 4             ; ���������� ��� �������� ����� (4 ����)
    password_input resb 16          ; ����� ��� ����� ������ (16 ����)
    password_len resb 4
    password_output resb 17 


section .text
    global _start
    
;----------------------------------------------------------------------------------------------------
   
_start:    

    mov rax, 1                      ; ��������� ����� write
    mov rdi, 1                      ; ���������� stdout
    mov rsi, prompt1                ; ��������� �� ������ �����������
    mov rdx, 73                     ; ����� ������ �����������
    syscall 

    mov rax, 0                      ; ��������� ����� read
    mov rdi, 0                      ; ���������� stdin
    mov rsi, password_input         ; ��������� �� ����� ��� �����
    mov rdx, 16                     ; ������������ ����� ����� (16 ��������)
    syscall 

    mov rax, 1                      ; ��������� ����� write
    mov rdi, 1                      ; ���������� stdout
    mov rsi, prompt3                ; ��������� �� ������ �����������
    mov rdx, 1                      ; ����� ������ �����������
    syscall 

    mov rax, 1                      ; ��������� ����� write
    mov rdi, 1                      ; ���������� stdout
    mov rsi, prompt2                ; ��������� �� ������ �����������
    mov rdx, 36                     ; ����� ������ �����������
    syscall 
;----------------------------------------------------------------------------------------------------

    mov rsi, password_input
    xor rax, rax                    ; �������� RAX (����� ��������� ���������)
    xor rcx, rcx                    ; �������� RCX (������� ����)

    .NEXT_CHAR:                     ; ����� ������ ������������� �� Enter
        mov bl, byte [rsi + rcx]    ; ��������� ��������� ������ �� ������
        cmp bl, 10                  ; ���������, �������� �� ����� ������ (������� ������)
        je .done                    ; ���� ��������, ��������� �������

        sub bl, '0'                 ; ����������� ������ � �����
        imul ax, 10                 ; �������� ������� ��������� �� 10
        add ax, bx                  ; ��������� ����� ����� � ����������

        inc cx                     ; ��������� � ���������� �������
        jmp .NEXT_CHAR              ; ��������� ����

        .done:
            mov [password_num], ax
            mov [password_len], cx

    ; � rax �������� ��������� ������������� ������ � �������� ���� 
;----------------------------------------------------------------------------------------------------
    
    mov rdi, password_num ; rsi - ����� ���������� ������

    FNV1A_HASH:
        ; ��������� FNV-1a
        mov ax, 0xcbf2          ; FNV offset basis
        mov cx, 0x11b3          ; FNV prime

        ; �����������
        xor dx, dx                    ; �������� rdx (�������)
        .HASH_LOOP:
            cmp rdx, [password_len]         ; ���������, �������� �� ����� ������
            jge .HASH_DONE                  ; ���� ��������, ��������� �����������

            mov bl, byte [rdi + rdx]        ; ��������� ��������� ���� �� ������
            xor ax, bx                      ; XOR ��� � ������
            imul ax, cx                     ; �������� ��� �� FNV prime

            inc rdx                         ; ��������� � ���������� �����
            jmp .HASH_LOOP                  ; ��������� ����

        .HASH_DONE:
            mov [password_num], ax
            mov ax, [password_num]
;----------------------------------------------------------------------------------------------------

    mov ax, [password_num]                ; ��������� ����� � rax
    mov rbx, password_output              ; ����� ��� ������
    call INT_TO_STRING

    mov rax, 1                      ; ��������� ����� write
    mov rdi, 1                      ; ���������� stdout
    mov rsi, password_output        ; ��������� �� ������ �����������
    mov rdx, 17                     ; ����� ������ �����������
    syscall 

    mov rax, 60                     ; ��������� ���������
    xor rdi, rdi
    syscall


;----------------------------------------------------------------------------------------------------

    INT_TO_STRING:
    mov cx, 4                      ; ���������� �������� � ax �����
   
    .LOOP:
        rol ax, 4                  ; ������� ����� ����� �� 4 ���� (����� ���������� ������� �����)
        mov dl, al                 ; ��������� ������� �����
        and dl, 0xF                ; ��������� ������ 4 ������� ����
        cmp dl, 10                 ; ���� ������ 10, ��� �����
        jl .DIGIT
        add dl, 'A' - 10           ; ����������� � ����� (A-F)
        jmp .STORE

    .DIGIT:
        add dl, '0'                ; ����������� � �����

    .STORE:
        mov [rbx], dl              ; ��������� ������ � �����
        inc rbx                    ; ������� � ��������� ������
        loop .LOOP                 ; ��������� ����

    mov byte [rbx], 0              ; ��������� ����-����������
    ret