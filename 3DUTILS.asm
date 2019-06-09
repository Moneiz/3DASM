extern XDrawLine
 
global projectVect
global canShow
projectVect:
    
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    
    mov al, BYTE[rdi]
    mov cl, 10
    imul cl
    mov cl,BYTE[rdi+2]
    add cl,5
    idiv cl
    mov ah,0
    add eax,100
    mov [rsi], eax
    
    mov al, BYTE[rdi+1]
    mov cl, 10
    imul cl    
    mov cl, BYTE[rdi+2]
    add cl,5
    idiv cl
    mov ah,0
    add eax,100
    mov [rsi+4], eax
    
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
   
   sub rsp,32 ; variable globale
   
   mov eax, [rdi]
   mov ecx, [rsi]
   sub ecx, eax
   mov [rbp-4],ecx  ;vect XAB
   
   mov eax, [rdi+4]
   mov ecx, [rsi+4]
   sub ecx, eax
   mov [rbp-8],ecx  ;vect YAB
   
   mov eax, [rdx]
   mov ecx, [rsi]
   sub ecx, eax
   mov [rbp-12],ecx ;vect XAC
   
   mov eax, [rdx+4]
   mov ecx, [rsi+4]
   sub ecx, eax
   mov [rbp-16],ecx ;vect YAC
   
   mov eax, [rbp-4]
   mov ecx,[rbp-12]
   imul ecx
   mov [rbp-24], eax
   mov [rbp-20], edx ;(XAB*YAC)
   
   mov eax, [rbp-8]
   mov ecx,[rbp-16]
   imul ecx
   mov [rbp-32], eax
   mov [rbp-28], edx ;(YAB*XAC)
   
   mov rdx, [rbp-24]
   mov rax, [rbp-32]
   
   cmp rdx,rax       ;normality
   jle can_show_return_0
   jg can_show_return_1 ; return 1 if positive
   
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