; aici am mai declarat niste variabile suplimentare
; care o sa ma ajute in program
section .data
    delim db " ", 0
    length dd 0
    sign dd 0
    text dd "", 0
; am folosit root pentru a stoca adresa radacinei, node
; pentru a stoca nodul atunci cand il aloc si il atribui
; si parent pentru a retine parintele nodurilor pe care
; le pun in arbore (in general lucrez cu parent atunci
; cand lucrez cu stiva - nodurile de la locul in care
; sunt in arbore si pana la radacina sunt puse pe stiva)    
section .bss
    root resd 1
    node resd 1
    parent resd 1

section .text
;; aici am mai declarat si alte functii pe care le folosesc
extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern printf
extern malloc
extern strtok
extern strcpy
extern strlen

global create_tree
global iocla_atoi

; functia de atoi
iocla_atoi:
; prima oara preiau argumentul
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov edx, 0
; folosesc text (declarat in section .data) - copiez
; in acesta sirul care trebuie transformat in numar
put_eax_in_text:
    mov ecx, [eax + edx]
    mov [text + edx], ecx
    add edx, 1
    cmp byte [eax + edx], 0
    jne put_eax_in_text

; aici aflu lungimea sirului ce trebuie transformat in numar
    mov ecx, -1
find_length:
    inc ecx
    cmp byte [text + ecx], 0
    jne find_length

; aici formez numarul propriu-zis, folosesc variabila length
; pentru a retine lungimea sirului de transformat in numar
    sub ecx, 1
    mov [length], ecx
    mov eax, 0
    mov ecx, 0
; verific daca numarul este cu semnul minus, caz in care voi
; incepe iterarea si formarea numarului nu de la caracterul
; de pe pozitia 0 din sir, ci de la pozitia 1 (omit semnul)
; folosesc conceptul abc = a * 100 + b * 10 + c (inmultesc
; repetat numarul cu 10 si adun valoarea cifrei = cod ASCII-48)
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
; daca sirul e negativ atunci inmultesc cu -1 (imul), daca nu
; atunci sar la sfarsitul functiei (return if_not_neg)
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
    jmp here_starts_check_sign
; label pe care il folosesc doar daca numarul
; nu este reprezentat de o singura cifra si are
; semn la inceput
remake_sign_0:
    mov dword [sign], 0
    jmp end_function
; aici verific daca elementul de pe pozitia 0 este
; un semn, caz in care modific o variabila ajutatoare
; (sign), facand-o 1
here_starts_check_sign:
    push ebp
    mov ebp, esp
    mov edx, [ebp + 8]
    mov dword [sign], 0
    cmp byte [edx], '+'
    je make_sign_1
    cmp byte [edx], '-'
    je make_sign_1
    cmp byte [edx], '/'
    je make_sign_1
    cmp byte [edx], '*'
    jne end_function
; aici fac variabila 1
; Daca insa urmatorul element (de pe poz 1) este altceva
; decat terminator de sir, atunci inseamna ca avem de a
; face cu un numar cu semn, astfel refacem sign 0 si sarim
; direct la sfarsit (end_function)
make_sign_1:
    mov dword [sign], 1
    cmp byte [edx + 1], 0
    jne remake_sign_0
end_function:
    leave
    ret

; functia in care creez tree-ul
create_tree:
    enter 0, 0

; Preluarea formei prefixate
    mov edx, [ebp + 8]

; Stergerea enter-ului de la sfarsitul sirului
; preluat ca argument
    mov ecx, -1
delete_enter:
    add ecx, 1
    cmp byte [edx + ecx], 10
    jne delete_enter
    mov byte [edx + ecx], 0

; preiau elementul din radacina arborelui folosind strtok
; ii calculez lungimea folosind strlen si memorez lungimea
; in length
    push delim
    push edx
    call strtok
    add esp, 8
    push eax
    push eax
    call strlen
    add esp, 4
    mov [length], eax
    add dword [length], 1

    xor eax, eax
; alocarea primului nod
    push 12
    call malloc
    add esp, 4
; adresele fiului stang si drept le initializez cu 0
    mov dword [eax + 4], 0
    mov dword [eax + 8], 0
; memoria alocata o pun in variabila node
    mov [node], eax
; aloc memorie pentru sirul care urmeaza sa fie memorat in
; nodul respectiv
    push dword [length]
    call malloc
    add esp, 4
    pop edx
; copiez sirul calculat in strtok cu strcpy la adresa unde am
; alocat memorie
    push edx
    push eax
    call strcpy
    add esp, 8
; pun la adresa dorita in cadrul lui node pointerul la sirul din eax
; trebuie sa dereferentiez de doua ori node, motiv pentru care folosesc ecx
    mov ecx, [node]
    mov [ecx], eax
    mov eax, ecx
; aici initiez parent si root cu adresa nodului alocat anterior
; pun in stiva acest nod pentru a putea sa ma reintorc inapoi daca cumva
; trebuie sa adaug un element pe alta ramura a arborelui
    mov ecx, [node]
    mov dword [parent], ecx
    mov dword [root], ecx
    push dword [node]
; sar direct la adaugarea unui nod stanga
    jmp add_left_node

add_left_node_after_right_sign:
    push dword [node]
    mov ecx, [node]
    mov [parent], ecx

; aici se adauga un nod care este left child
add_left_node:
; apelez din nou strtok pentru a continua sa aflu
; urmatorul element din sirul in forma prefixata
    push delim
    push 0
    call strtok
    add esp, 8
; daca strtok returneaza 0 atunci nu mai am elemente
; de pus in arbore si sar la sfarsitul functiei
    cmp eax, 0
    je end_create_tree
    push eax
    push eax
    call strlen
    add esp, 4
    mov [length], eax
    add dword [length], 1
; aloc nodul in mod similar
    push 12
    call malloc
    add esp, 4
; initializez pointerii left child si right child cu 0
; aloc memorie pentru sirul din nod
    mov dword [eax + 4], 0
    mov dword [eax + 8], 0
    mov [node], eax
    push dword [length]
    call malloc
    add esp, 4
    pop edx
; aici copiez sirul reprezentat de elementul luat din sir
; in memoria alocata pentru sirul din nod
    push edx
    push eax
    call strcpy
    add esp, 8
; aici pun sirul la adresa buna pentru nod (similar cu ce
; am facut anterior) si pun la parent + 4 adresa nodului alocat
; (left child)
    mov ecx, [node]
    mov [ecx], eax
    mov edx, [parent]
    mov dword [edx + 4], ecx
; verific daca nodul pus era un semn sau un numar
; daca e un numar (sign este 0), atunci inseamna ca el
; nu va mai avea fi si atunci va trebui sa trec la punerea unui
; nod la dreapta lui parent. Daca este semn, atunci nodul alocat
; va deveni parent, iar cel care era parent inainte il pun pe stiva
; si sar la adaugarea unui fiu stang pentru noul parinte
    push eax
    call check_sign
    add esp, 4
    cmp dword [sign], 0
    je add_right_node
    push dword [node]
    mov ecx, [node]
    mov [parent], ecx
    jmp add_left_node

; aici se adauga un nod care este right child
add_right_node:
; apelez din nou strtok pentru a continua sa aflu
; urmatorul element din sirul in forma prefixata
    push delim
    push 0
    call strtok
    add esp, 8 
; daca strtok returneaza 0 atunci nu mai am elemente
; de pus in arbore si sar la sfarsitul functiei
    cmp eax, 0
    je end_create_tree
; eticheta auxiliara pentru adaugarea unui nod right child
add_right_aux:
    push eax
; aloc memorie pentru nod (similar cu ce am facut anterior)
    push 12
    call malloc
    add esp, 4
; intializez left child si right child pointers cu 0
; aloc memorie pt sir 
    mov dword [eax + 4], 0
    mov dword [eax + 8], 0
    mov [node], eax
    push 15
    call malloc
    add esp, 4
    pop edx
; copiez cu strcpy sirul la memoria alocata
    push edx
    push eax
    call strcpy
    add esp, 8
; pun sirul in nodul alocat, pun right child-ul nodului
; parinte sa fie acest nod alocat
    mov ecx, [node]
    mov [ecx], eax
    mov edx, [parent]
    mov dword [edx + 8], ecx
; daca nodul alocat acum a fost un semn atunci trebuie sa
; il pun pe stiva si sa il schimb pe el sa fie parent si
; sa continui sa ii adaug acestuia nod la stanga
    push eax
    call check_sign
    add esp, 4
    cmp dword [sign], 1
    je add_left_node_after_right_sign
; daca am atribuit right child-ul, atunci preiau urmatorul
; element din sir (cum am facut anterior), strtok-ul urmator
; il pun aici ca sa evit sa pun ce e in loop_parent mai sus
    push delim
    push 0
    call strtok
    add esp, 8
    cmp eax, 0
    je end_create_tree
; in loop_parent scot pe rand parintii din stiva pana cand
; gasesc unul care nu are nod right_child, moment in care aceluia
; trebuie sa ii adaug un right child 
loop_parent:
    pop dword [parent]
    mov ecx, [parent]
    cmp dword [ecx + 8], 0
    jne loop_parent
    jmp add_right_aux

; la sfarsit pun intotdeauna in eax pe root
; (radacina arborelui)
end_create_tree:
    mov ecx, [root]
    mov eax, ecx

    leave
    ret
