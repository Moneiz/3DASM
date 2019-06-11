extern printf
 
global projectVect
global canShow
global rotate

debug_: db "%d",10,0
demiangle: dd 180

projectVect:
    
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    
    sub rsp,16 ; variables locales
    
    ; Calcul X' à partie X et Z
    movsx ax, BYTE[rdi]
    mov cx, 180
    imul cx
    mov [rbp-2],dx
    mov [rbp-4],ax
    mov eax,[rbp-4]
    movsx ecx,BYTE[rdi+2]
    add ecx,40
    cdq
    idiv ecx
    add eax,200
    mov [rsi], eax
    
    ; Calcul Y' depuis Y et Z
    xor rax,rax ; rax à 0
    movsx ax, BYTE[rdi+1] ; ax = Y
    mov cx, 220; cx = df
    imul cx 
    mov [rbp-2],dx
    mov [rbp-4],ax
    mov eax,[rbp-4] ; eax=(Y*df)
    movsx ecx,BYTE[rdi+2] ; ecx = Z
    add ecx,40 ; ecx = Zoff
    cdq ; important : coords 3D pouvant être négative
    idiv ecx ; eax = (Y*df)/(Zoff+Z)
    add eax,200 ; eax = (Y*df)/(Zoff+Z) + Yoff
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

; rotate(char rdi, char rsi, char rdx
; vec3* rcx)
; - rdi - X_rotation
; - rsi - Y_rotation
; - rdx - Z_rotation
; - rcx - address_sommet
rotate:

    push rbp
    mov rbp,rsp

    sub rsp, 48
    
    movsx eax,BYTE[r8]
    mov [rbp-4], eax ; X en variable locale
    
    movsx eax,BYTE[r8+1]
    mov [rbp-8], eax ; Y en variable locale
    
    movsx eax,BYTE[r8+2]
    mov [rbp-12], eax ; Z en variable locale
    
    mov [rbp-16],edi ; x_rotation
    mov [rbp-40],esi ; y_rotation
    mov [rbp-44],edx ; z_rotation
    
    ; APPLY X ROTATION
    fldpi
    fimul dword[rbp-16]
    fidiv dword[demiangle]
    fsincos
    fstp dword[rbp-20] ; cos(x)
    fstp dword[rbp-24] ; sin(x)
    
    ; y' calcule
    fld dword[rbp-20]
    fimul dword[rbp-8] ; y*cos(x)
    fstp dword[rbp-28]
    
    fld dword[rbp-24]
    fimul dword[rbp-12] ; z*sin(x)
    fstp dword[rbp-32]
    
    fld dword[rbp-28]
    fsub dword[rbp-32] ; y*cos(x) - z*sin(x)
    fistp dword[rbp-36]
    
    mov al, byte[rbp-36]
    mov BYTE[rcx+1],al ; update ypos by y'
    
    
    ; z' calcule
    fld dword[rbp-20]
    fimul dword[rbp-12] ; z*cos(x)
    fstp dword[rbp-28]
    
    fld dword[rbp-24]
    fimul dword[rbp-8] ; y*sin(x)
    fstp dword[rbp-32]
    
    fld dword[rbp-28]
    fadd dword[rbp-32] ; z*cos(x) + y*sin(x)
    fistp dword[rbp-36]
    
    mov al, byte[rbp-36]
    mov BYTE[rcx+2],al ; update ypos by y'
    
    movsx eax,BYTE[rcx+1]
    mov [rbp-8], eax ; Y en variable locale
    
    movsx eax,BYTE[rcx+2]
    mov [rbp-12], eax ; Z en variable locale
    
    ; APPLY Y ROTATION
    fldpi
    fimul dword[rbp-40] ; y
    fidiv dword[demiangle]
    fsincos
    fstp dword[rbp-20] ; cos(y)
    fstp dword[rbp-24] ; sin(y)
    
    ; y' calcule
    fld dword[rbp-20]
    fimul dword[rbp-4] ; x*cos(y)
    fstp dword[rbp-28]
    
    fld dword[rbp-24]
    fimul dword[rbp-12] ; z*sin(y)
    fstp dword[rbp-32]
    
    fld dword[rbp-28]
    fadd dword[rbp-32] ; x*cos(y) + z*sin(y)
    fistp dword[rbp-36]
    
    mov al, byte[rbp-36]
    mov BYTE[rcx],al
    
    
    ; z' calcule
    fld dword[rbp-20]
    fimul dword[rbp-12] ; z*cos(y)
    fstp dword[rbp-28]
    
    fld dword[rbp-24]
    fimul dword[rbp-4] ; x*sin(y)
    fstp dword[rbp-32]
    
    fld dword[rbp-28]
    fsub dword[rbp-32] ; z*cos(y) - x*sin(y)
    fistp dword[rbp-36]
    
    mov al, byte[rbp-36]
    mov BYTE[rcx+2],al

    
    add rsp, 48
    
    mov rsp, rbp
    pop rbp
    ret