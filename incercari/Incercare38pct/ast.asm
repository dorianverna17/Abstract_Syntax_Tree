%include "printf32.asm"

section .data
    delim db " ", 0
    length dd 0
    sign dd 0
    text dd "", 0
section .bss
    root resd 1
    current resd 1
    parent resd 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern printf
extern malloc
extern strtok
extern strcpy
extern atoi

global create_tree
global iocla_atoi

; functia de atoi
iocla_atoi:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov edx, 0
put_eax_in_text:
    mov ecx, [eax + edx]
    mov [text + edx], ecx
    add edx, 1
    cmp byte [eax + edx], 0
    jne put_eax_in_text

    mov ecx, -1
find_length:
    inc ecx
    cmp byte [text + ecx], 0
    jne find_length

    sub ecx, 1
    mov [length], ecx
    mov eax, 0
    mov ecx, 0
form_number:
    cmp byte [text + ecx], '-'
    je loop_if_negative
    mov edx, eax
    mov eax, 10
    mul edx
    xor edx, edx
    mov dl, byte [text + ecx] 
    add eax, edx
    sub eax, 48
loop_if_negative:
    add ecx, 1
    cmp ecx, [length]
    jle form_number
    cmp byte [text], '-'
    jne return_if_not_neg
    mov edx, eax
    mov eax, -1
    imul edx
return_if_not_neg:
    leave
    ret

; Functie care verifica daca elementul din
; din sir care urmeaza sa fie adaugat in arbore
; este un semn sau este numar
check_sign:
    mov dword [sign], 0
    mov edx, [esp + 4]
    PRINTF32 `%s\n\x0`, edx
    cmp byte [edx], '+'
    je make_sign_1
    cmp byte [edx], '-'
    je make_sign_1
    cmp byte [edx], '/'
    je make_sign_1
    cmp byte [edx], '*'
    jne sign_remains_0
make_sign_1:
    mov dword [sign], 1
sign_remains_0:
    leave
    ret

create_tree:
    enter 0, 0

; Preluarea formei prefixate
    mov edx, [ebp + 8]

; Stergerea enter-ului de la sfarsitul sirului
; preluat de la tastatura
    mov ecx, -1
delete_enter:
    add ecx, 1
    cmp byte [edx + ecx], 10
    jne delete_enter
    mov byte [edx + ecx], 0

put_elements_on_stack:
    push delim
    push edx
    call strtok
    add esp, 8
    push eax

    xor eax, eax

; alocarea primului nod
    push 12
    call malloc
    add esp, 4

    mov dword [eax + 4], 0
    mov dword [eax + 8], 0
    mov [root], eax
    push 15
    call malloc
    add esp, 4
    pop edx

    push edx
    push eax
    call strcpy
    add esp, 8

    mov ecx, [root]
    mov [ecx], eax
    mov eax, ecx

    mov ecx, [root]
    mov dword [parent], ecx

iterareaza_prin_sir:
;; nod stanga
    push delim
    push 0
    call strtok
    add esp, 8
    push eax

    push 12
    call malloc
    add esp, 4

    mov dword [eax + 4], 0
    mov dword [eax + 8], 0
    mov [root], eax
    push 15
    call malloc
    add esp, 4
    pop edx

    push edx
    push eax
    call strcpy
    add esp, 8

    mov ecx, [root]
    mov [ecx], eax
    mov edx, [parent]
    mov dword [edx + 4], ecx

;; nod dreapta
    push delim
    push 0
    call strtok
    add esp, 8
    push eax

    push 12
    call malloc
    add esp, 4

    mov dword [eax + 4], 0
    mov dword [eax + 8], 0
    mov [root], eax
    push 15
    call malloc
    add esp, 4
    pop edx

    push edx
    push eax
    call strcpy
    add esp, 8

    mov ecx, [root]
    mov [ecx], eax
    mov edx, [parent]
    mov dword [edx + 8], ecx

; asta e intotdeauna la sfarsit
    mov ecx, [parent]
    mov eax, ecx

end_create_tree:
    leave
    ret
