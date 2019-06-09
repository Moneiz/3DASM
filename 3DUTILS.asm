extern printf
 
global projectVect
global canShow

debug_: db "%d",10,0

projectVect:
    
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    
    sub rsp,16 ; variables locales
    
    ; Calcul X' à partie X et Z
    movsx ax, BYTE[rdi]
    mov cx, 30
    imul cx
    mov [rbp-2],dx
    mov [rbp-4],ax
    mov eax,[rbp-4]
    movsx ecx,BYTE[rdi+2]
    add ecx,2
    cdq
    idiv ecx
    add eax,100
    mov [rsi], eax
    
    ; Calcul Y' depuis Y et Z
    xor rax,rax ; rax à 0
    movsx ax, BYTE[rdi+1] ; ax = Y
    mov cx, 30 ; cx = df
    imul cx 
    mov [rbp-2],dx
    mov [rbp-4],ax
    mov eax,[rbp-4] ; eax=(Y*df)
    movsx ecx,BYTE[rdi+2] ; ecx = Z
    add ecx,2 ; ecx = Zoff
    cdq ; important : coords 3D pouvant être négative
    idiv ecx ; eax = (Y*df)/(Zoff+Z)
    add eax,100 ; eax = (Y*df)/(Zoff+Z) + Yoff
    mov [rsi+4], eax
    
    add rsp,16
    
    pop rcx
    pop rbx
    mov rsp, rbp
    pop rbp
    
    ret

;Fonction qui indique si deux vecteurs
;d'une face peuvent l'afficher
canShow:
   push rbp
   mov rbp, rsp
   push rcx
   
   sub rsp,32 ; variables locales
   
   mov eax, [rsi]
   mov ecx, [rdi]
   sub ecx, eax ; ecx = XB - XA
   mov [rbp-4],ecx  ;vect XAB
   
   mov eax, [rsi+4]
   mov ecx, [rdi+4]
   sub ecx, eax ; ecx = YB - YA
   mov [rbp-8],ecx  ;vect YAB
   
   mov eax, [rdx]
   mov ecx, [rdi]
   sub ecx, eax ; ecx = XC - XA
   mov [rbp-12],ecx ;vect XAC
   
   mov eax, [rdx+4]
   mov ecx, [rdi+4]
   sub ecx, eax ; ecx = YC - YA
   mov [rbp-16],ecx ;vect YAC
   
   mov eax, [rbp-4]
   mov ecx,[rbp-16]
   imul ecx  ;(XAB*YAC)
   mov [rbp-24], eax
   mov [rbp-20], edx 
   
   mov eax, [rbp-8]
   mov ecx,[rbp-12]
   imul ecx ;(YAB*XAC)
   mov [rbp-32], eax
   mov [rbp-28], edx 
   
   mov rdx, [rbp-24]
   mov rax, [rbp-32]
   
   ; retourne la valeur selon la
   ; normal
   cmp rdx,rax       
   jle can_show_return_0
   jg can_show_return_1
   
   can_show_return_1:
    mov rax, 1
    jmp can_show_end
   can_show_return_0:
    mov rax, 0
    jmp can_show_end
   
   
   can_show_end:
   
   add rsp,32
   
   pop rcx
   pop rbp

   ret