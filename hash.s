section .data:
    prompt1 db "Enter a decimal number (you can also enter letters, but that's a secret): ", 0  ; Приглашение для ввода
    prompt2 db "Here, your hash is a baller hacker: ", 0  
    prompt3 db 10

section .bss
    password_num resb 4             ; Variable for storing a number (4 bytes)
    password_input resb 16          ; String input buffer (16 bytes)
    password_len resb 4
    password_output resb 17 


section .text
    global _start
    
;----------------------------------------------------------------------------------------------------
   
_start:    

    mov rax, 1                      ; System call write
    mov rdi, 1                      ; Descriptor stdout
    mov rsi, prompt1                ; Pointer to the invitation string
    mov rdx, 73                     ; Invitation string length
    syscall 

    mov rax, 0                      ; System call read
    mov rdi, 0                      ; Descriptor stdin
    mov rsi, password_input         ; Pointer to input buffer
    mov rdx, 16                     ; Maximum input length (16 characters)
    syscall 

    mov rax, 1                      ; System call write
    mov rdi, 1                      ; Descriptor stdout
    mov rsi, prompt3                ; Pointer to the invitation string
    mov rdx, 1                      ; Invitation string length
    syscall 

    mov rax, 1                      ; System call write
    mov rdi, 1                      ; Descriptor stdout
    mov rsi, prompt2                ; Pointer to the invitation string
    mov rdx, 36                     ; Invitation string length
    syscall 
;----------------------------------------------------------------------------------------------------

    mov rsi, password_input
    xor rax, rax                    ; Обнуляем RAX (будет содержать результат)
    xor rcx, rcx                    ; Обнуляем RCX (счётчик цифр)

    .NEXT_CHAR:                     ; Конец строки расчитывается по Enter
        mov bl, byte [rsi + rcx]    ; Загружаем очередной символ из строки
        cmp bl, 10                  ; Проверяем, достигли ли конца строки (нулевой символ)
        je .done                    ; Если достигли, завершаем функцию

        sub bl, '0'                 ; Преобразуем символ в цифру
        imul ax, 10                 ; Умножаем текущий результат на 10
        add ax, bx                  ; Добавляем новую цифру к результату

        inc cx                     ; Переходим к следующему символу
        jmp .NEXT_CHAR              ; Повторяем цикл

        .done:
            mov [password_num], ax
            mov [password_len], cx

    ; в rax хранится введенным пользователем пароль в числовом виде 
;----------------------------------------------------------------------------------------------------
    
    mov rdi, password_num ; rsi - адрес введенного пароля

    FNV1A_HASH:
        ; Константы FNV-1a
        mov ax, 0xcbf2          ; FNV offset basis
        mov cx, 0x11b3          ; FNV prime

        ; Хэширование
        xor dx, dx                    ; Обнуляем rdx (счетчик)
        .HASH_LOOP:
            cmp rdx, [password_len]         ; Проверяем, достигли ли конца строки
            jge .HASH_DONE                  ; Если достигли, завершаем хэширование

            mov bl, byte [rdi + rdx]        ; Загружаем очередной байт из строки
            xor ax, bx                      ; XOR хэш с байтом
            imul ax, cx                     ; Умножаем хэш на FNV prime

            inc rdx                         ; Переходим к следующему байту
            jmp .HASH_LOOP                  ; Повторяем цикл

        .HASH_DONE:
            mov [password_num], ax
            mov ax, [password_num]
;----------------------------------------------------------------------------------------------------

    mov ax, [password_num]                ; Загружаем число в rax
    mov rbx, password_output              ; Буфер для вывода
    call INT_TO_STRING

    mov rax, 1                      ; Системный вызов write
    mov rdi, 1                      ; Дескриптор stdout
    mov rsi, password_output        ; Указатель на строку приглашения
    mov rdx, 17                     ; Длина строки приглашения
    syscall 

    mov rax, 60                     ; Завершаем программу
    xor rdi, rdi
    syscall


;----------------------------------------------------------------------------------------------------

    INT_TO_STRING:
    mov cx, 4                      ; Количество символов в ax числе
   
    .LOOP:
        rol ax, 4                  ; Двигаем число влево на 4 бита (чтобы обработать старший ниббл)
        mov dl, al                 ; Загружаем младший ниббл
        and dl, 0xF                ; Оставляем только 4 младших бита
        cmp dl, 10                 ; Если меньше 10, это цифра
        jl .DIGIT
        add dl, 'A' - 10           ; Преобразуем в букву (A-F)
        jmp .STORE

    .DIGIT:
        add dl, '0'                ; Преобразуем в цифру

    .STORE:
        mov [rbx], dl              ; Сохраняем символ в буфер
        inc rbx                    ; Переход к следующей ячейке
        loop .LOOP                 ; Повторяем цикл

    mov byte [rbx], 0              ; Добавляем нуль-терминатор

    ret
