; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XClearWindow
extern XNextEvent

; external functions from stdio library (ld-linux-x86-64.so.2)    
extern printf
extern exit

extern projectVect
extern canShow
extern rotate
extern scale

%define	StructureNotifyMask	131072
%define KeyPressMask		1
%define ButtonPressMask		4
%define MapNotify		19
%define KeyPress		2
%define ButtonPress		4
%define Expose			12
%define ConfigureNotify		22
%define CreateNotify 16
%define QWORD	8
%define DWORD	4
%define WORD	2
%define BYTE	1

global main

section .bss
display_name:	resq	1
screen:		resd	1
depth:         	resd	1
connection:    	resd	1
width:         	resd	1
height:        	resd	1
window:		resq	1
gc:		resq	1

section .data

event:		times	24 dq 0

;original 3d coords
opt1:    dw  -10,-10,-10
opt2:    dw  10, -10,-10
opt3:    dw  10, 10,-10
opt4:    dw  -10,10,-10
opt5:    dw  10,-10,10
opt6:    dw  -10,-10,10
opt7:    dw  -10,10,10
opt8:    dw  10,10,10
opt9:    dw  0,25,0
opt10:  dw  0,-25,0


;modelviewed 3d coords
pt1:    dw  -10,-10,-10
pt2:    dw  10, -10,-10
pt3:    dw  10, 10,-10
pt4:    dw  -10,10,-10
pt5:    dw  10,-10,10
pt6:    dw  -10,-10,10
pt7:    dw  -10,10,10
pt8:    dw  10,10,10
pt9:    dw  0,15,0  ;extra
pt10:   dw  0,-15,0

;2d coords projection
pjpt1:  dd  0,0
pjpt2:  dd  0,0
pjpt3:  dd  0,0
pjpt4:  dd  0,0
pjpt5:  dd  0,0
pjpt6:  dd  0,0
pjpt7:  dd  0,0
pjpt8:  dd  0,0
pjpt9:  dd  0,0
pjpt10: dd  0,0

;rotation
rotx:   dw  0
roty:   dw  0
rotz:   dw  0

; faces map
face1:  db  0,1,2,3
face2:  db  1,4,7,2
face3:  db  4,5,6,7
face4:  db  5,0,3,6
face5:  db  6,3,8,8
face6:  db  3,2,8,8
face7:  db  2,7,8,8
face8:  db  7,6,8,8
face9:  db  4,1,9,9
face10: db  1,0,9,9
face11: db  0,5,9,9
face12: db  5,4,9,9

; debug message
vertex: db "Vertex %hhd -> %hhd,%hhd",10,0 
faceMsg: db "Face %hhd",10,0

;coords buffer
x1:     dd  0
x2:     dd  0
y1:     dd  0
y2:     dd  0

section .text

;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################

main:
xor     rdi,rdi
call    XOpenDisplay	; Création de display
mov     qword[display_name],rax	; rax=nom du display

; display_name structure
; screen = Default
;Screen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax

mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax

mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400	; largeur
mov r9,400	; hauteur
push 0x000000	; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax

mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput

mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow

mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax

mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000 ; Couleur du crayon
call XSetForeground

boucle: ; boucle de gestion des évènements
mov rdi,qword[display_name]
mov rsi,event
call XNextEvent

cmp dword[event],ConfigureNotify	; à l'apparition de la fenêtre
je dessin							; on saute au label 'dessin'

cmp dword[event],KeyPress			; Si on appuie sur une touche
je rotation_event						; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle

;#########################################
;#		DEBUT DE LA ZONE DE DESSIN		 #
;#########################################
rotation_event:
    mov rdi,qword[display_name]
    mov rsi,qword[window] 
    call XClearWindow

    mov ax, 5
    add [rotx],ax
    mov ax, 5
    add [roty],ax
    
    mov rdi,qword[display_name]
    mov rsi,qword[gc]
    mov rdx,0x0000FF	; Couleur du crayon
    add dh,[roty]
    call XSetForeground
    
    jmp dessin
    
    

dessin:



mov rcx,0 ; compteur à zero

forpts: ; boucle for
 push rcx

 ;envoie des rotations en paramètre
 movsx rdi,word[rotx]
 movsx rsi,word[roty]
 movsx rdx,word[rotz]
 push rcx
 
 mov rbx,opt1 
 xor rax,rax
 mov al,6
 mul cl
 add rbx,rax
 mov r8, rbx
 
 mov rbx,pt1 
 xor rax,rax
 mov al,6
 mul cl
 add rbx,rax
 mov rcx, rbx

 call rotate
 
 mov ax,1
 movsx rdi,ax
 movsx rsi,ax
 movsx rdx,ax
 
 call scale
 
 pop rcx
 
 ;push rcx
 ;mov rdi, vertex
 ;mov rsi, rcx
 ;mov rdx, [rbx+1]
 ;mov rcx, [rbx+2]
 ;mov rax,0
 ;call printf
 ;pop rcx

 ;passation du paramètre des points 3D
 mov rbx,pt1 
 xor rax,rax
 mov al,6
 mul cl
 add rbx,rax
 mov rdi, rbx
 
 ;passation du paramètre des points 2D
 mov rbx,pjpt1
 xor rax,rax
 mov al,8
 mul cl
 add rbx,rax
 mov rsi, rbx
 
 
 ;Appel de la fonction:
 ; projectVect(vec3 rdi,vec2 rsi)
 call projectVect
 
 pop rcx
 inc cl
 cmp cl,10 ; 10 iérations = nb sommets
 jb forpts
 
mov cl,0 ; compteur à zero
forfaces:
 mov rbx,face1
 mov rax,4
 mul cl
 add rbx,rax ; rbx = adresse face itérée
 
 push rcx
 
 ; vecteur position 1  (commun)
 mov rcx, pjpt1
 mov ah,8
 mov al, [rbx]
 mul ah
 add rcx, rax
 mov rdi,rcx  

 ; vecteur position 2
 mov rcx, pjpt1
 mov ah,8
 mov al, [rbx+1]
 mul ah
 add rcx, rax
 mov rsi,rcx 
 
 ; vecteur position 3
 mov rcx, pjpt1
 mov ah,8
 mov al, [rbx+3]
 mul ah
 add rcx, rax
 mov rdx,rcx 
 
 ;Appel de la fonction de face
 ;canShow(vec2 rdi, vec2 rsi, vec rdx) 
 call canShow
 
 pop rcx
 
 ; si la fonction retourne 1,
 ; on affiche la face
 ; sinon on continue la boucle
 cmp rax,1
 jne endforfaces
    
 ;greyfaces:
 ;   mov rdi,qword[display_name]
 ;   mov rsi,qword[gc]
 ;   mov rdx,0x333333	; Couleur du crayon
 ;   call XSetForeground
 ;   jmp after_face_color
 ;whitefaces:
 ;   mov rdi,qword[display_name]
 ;   mov rsi,qword[gc]
 ;   mov rdx,0xFFFFFF	; Couleur du crayon
 ;   call XSetForeground
 ;   jmp after_face_color
 ;after_face_color:
 
 push rcx ; empilement de rcx

  ; debug affiche la face affichées
  mov rdi, faceMsg
  mov rsi, rcx
  mov rax,0
  call printf

  ; recuperation des coords 2D 
  ; à partir des  sommets 1
  ; de la face
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x1],ecx
  mov ecx, [rax+4]
  mov [y1],ecx
 
  ; recuperation des coords 2D 
  ; à partir des  sommets 2
  ; de la face
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+1]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x2],ecx
  mov ecx, [rax+4]
  mov [y2],ecx
 
 ; Dessine la ligne entre 1 et 2
  mov rdi,qword[display_name]
  mov rsi,qword[window]
  mov rdx,qword[gc]
  mov ecx,dword[x1]	; coordonnée source en x
  mov r8d,dword[y1]	; coordonnée source en y
  mov r9d,dword[x2]	; coordonnée destination en x
  push qword[y2]		; coordonnée destination en y
  call XDrawLine
  pop rcx
 
 ; recuperation des coords 2D 
  ; à partir des  sommets 2
  ; de la face
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+1]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x1],ecx
  mov ecx, [rax+4]
  mov [y1],ecx
 
 ; recuperation des coords 2D 
  ; à partir des  sommets 3
  ; de la face
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+2]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x2],ecx
  mov ecx, [rax+4]
  mov [y2],ecx
 
 ; Dessine la ligne entre 2 et 3
  mov rdi,qword[display_name]
  mov rsi,qword[window]
  mov rdx,qword[gc]
  mov ecx,dword[x1]	; coordonnée source en x
  mov r8d,dword[y1]	; coordonnée source en y
  mov r9d,dword[x2]	; coordonnée destination en x
  push qword[y2]		; coordonnée destination en y
  call XDrawLine
  pop rcx
  
  ; recuperation des coords 2D 
  ; à partir des  sommets 3
  ; de la face
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+2]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x1],ecx
  mov ecx, [rax+4]
  mov [y1],ecx
 
 ; recuperation des coords 2D 
  ; à partir des  sommets 4
  ; de la face
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+3]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x2],ecx
  mov ecx, [rax+4]
  mov [y2],ecx
 
 ; Dessine la ligne entre 3 et 4
  mov rdi,qword[display_name]
  mov rsi,qword[window]
  mov rdx,qword[gc]
  mov ecx,dword[x1]	; coordonnée source en x
  mov r8d,dword[y1]	; coordonnée source en y
  mov r9d,dword[x2]	; coordonnée destination en x
  push qword[y2]		; coordonnée destination en y
  call XDrawLine
  pop rcx
  
  ; recuperation des coords 2D 
  ; à partir des  sommets 4
  ; de la face
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx+3]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x1],ecx
  mov ecx, [rax+4]
  mov [y1],ecx
 
 ; recuperation des coords 2D 
  ; à partir des  sommets 1
  ; de la face
  mov rax,0
  mov rcx,pjpt1
  mov al, 8
  mov ah, [rbx]
  mul ah
  add rcx, rax
  mov rax, rcx
  mov ecx, [rax]
  mov [x2],ecx
  mov ecx, [rax+4]
  mov [y2],ecx
 
  ; Dessine la ligne entre 4 et 1
  mov rdi,qword[display_name]
  mov rsi,qword[window]
  mov rdx,qword[gc]
  mov ecx,dword[x1]	; coordonnée source en x
  mov r8d,dword[y1]	; coordonnée source en y
  mov r9d,dword[x2]	; coordonnée destination en x
  push qword[y2]		; coordonnée destination en y
  call XDrawLine
  pop rcx
  
  pop rcx
 
 endforfaces:
 
 
 inc cl
 cmp cl, 12 ; on itère pour les 6 faces
 jb forfaces



; ############################
; # FIN DE LA ZONE DE DESSIN #
; ############################
jmp flush

flush:
mov rdi,qword[display_name]
call XFlush
jmp boucle
mov rax,34
syscall

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor	    rdi,rdi
    call    exit
	
