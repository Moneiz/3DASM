extern XDrawLine
 
global projectVect
global drawFace
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

drawFace:
 call XDrawLine