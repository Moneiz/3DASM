extern printf
 
global projectVect
global canShow
global rotate
global scale

debug_: db "%d",10,0
demiangle: dd 180

projectVect:
    
    push rbp
    mov rbp, rsp
    push rbx
    push rcx
    
    sub rsp,16 ; variables locales
    
    ; Calcul X' à partie X et Z
    mov ax, WORD[rdi]
    mov cx, 180
    imul cx
    mov [rbp-2],dx
    mov [rbp-4],ax
    mov eax,[rbp-4]
    movsx ecx,Word[rdi+4]
    add ecx,80
    cdq
    idiv ecx
    add eax,200
    mov [rsi], eax
    
    ; Calcul Y' depuis Y et Z
    xor rax,rax ; rax à 0
    mov ax, Word[rdi+2] ; ax = Y
    mov cx, 220; cx = df
    imul cx 
    mov [rbp-2],dx
    mov [rbp-4],ax
    mov eax,[rbp-4] ; eax=(Y*df)
    movsx ecx,Word[rdi+4] ; ecx = Z
    add ecx,80 ; ecx = Zoff
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
; vec3* rcx,vec3* r8)
; - rdi - X_rotation
; - rsi - Y_rotation
; - rdx - Z_rotation
; - r8 - address_sommet_origin
; - rcx - address_sommet_modelviewed
rotate:

    push rbp
    mov rbp,rsp

    sub rsp, 48 ; voir fiche variable
    
    movsx eax,word[r8]
    mov [rbp-4], eax ; X en variable locale
    
    movsx eax,word[r8+2]
    mov [rbp-8], eax ; Y en variable locale
    
    movsx eax,word[r8+4]
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
    
    mov ax, word[rbp-36]
    mov WORD[rcx+2],ax ; update ypos by y'
    
    
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
    
    mov ax, WORD[rbp-36]
    mov WORD[rcx+4],ax ; update ypos by y'
    
    movsx eax,word[rcx+2]
    mov [rbp-8], eax ; mise à jour de y
    
    movsx eax,word[rcx+4]
    mov [rbp-12], eax ; mise à jour de z
    
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
    
    mov ax, WORD[rbp-36]
    mov WORD[rcx],ax
    
    
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
    
    mov ax, WORD[rbp-36]
    mov WORD[rcx+4],ax
    
    movsx eax,WORD[rcx]
    mov [rbp-4], eax ; mise à jour de x
    
    movsx eax,WORD[rcx+4]
    mov [rbp-12], eax ; mise à jour de z

    ; APPLY Z ROTATION
    fldpi
    fimul dword[rbp-44] ; z
    fidiv dword[demiangle]
    fsincos
    fstp dword[rbp-20] ; cos(z)
    fstp dword[rbp-24] ; sin(z)
    
    ; x' calcule
    fld dword[rbp-20]
    fimul dword[rbp-4] ; x*cos(z)
    fstp dword[rbp-28]
    
    fld dword[rbp-24]
    fimul dword[rbp-8] ; y*sin(z)
    fstp dword[rbp-32]
    
    fld dword[rbp-28]
    fsub dword[rbp-32] ; x*cos(z) - y*sin(z)
    fistp dword[rbp-36]
    
    mov ax, WORD[rbp-36]
    mov WORD[rcx],ax
    
    
    ; y' calcule
    fld dword[rbp-20]
    fimul dword[rbp-8] ; y*cos(z)
    fstp dword[rbp-28]
    
    fld dword[rbp-24]
    fimul dword[rbp-4] ; x*sin(z)
    fstp dword[rbp-32]
    
    fld dword[rbp-28]
    fadd dword[rbp-32] ; y*cos(z) + x*sin(z)
    fistp dword[rbp-36]
    
    mov ax, WORD[rbp-36]
    mov WORD[rcx+2],ax
    
    add rsp, 48
    
    mov rsp, rbp
    pop rbp
    ret
    
; rotate(char rdi, char rsi, char rdx
; vec3* rcx,vec3* r8)
; - rdi - X_scale
; - rsi - Y_scale
; - rdx - Z_scale
; - rcx - address_sommet_modelviewed
scale:

    push rbp
    mov rbp,rsp

    sub rsp, 16 ; voir fiche variable
    
    mov ax,word[rcx]
    mov [rbp-2], ax ; X en variable locale
    
    mov ax,word[rcx+2]
    mov [rbp-4], ax ; Y en variable locale
    
    mov ax,word[rcx+4]
    mov [rbp-6], ax ; Z en variable locale
    
    mov [rbp-8],di ; x_scale
    mov [rbp-10],si ; y_scale
    mov [rbp-12],dx ; z_scale
    
    mov ax, [rbp-2]
    mov bx, [rbp-8]
    imul bx
    mov [rcx],ax
    
    mov ax, [rbp-4]
    mov bx, [rbp-10]
    imul bx
    mov [rcx+2],ax
    
    mov ax, [rbp-6]
    mov bx, [rbp-12]
    imul bx
    mov [rcx+4],ax
    
    add rsp, 16
    
    mov rsp, rbp
    pop rbp
    ret