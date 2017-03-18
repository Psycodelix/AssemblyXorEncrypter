format MZ   

entry code_seg:start 

stack 256
    
      
segment data_seg
 
 str1: db "Digite sua string:$"
    
    xorkey: db "Digite sua chave (max. 255):$"
        
        EncryptedText: db "Encriptado:$"
        
            hexatable: db "0123456789ABCDEF"
        
                xorkey1: db 4,00,4 dup (0)
            
                    InputStr: db 255,00
                    	  
segment code_seg
  start:
  
    mov ax, data_seg
    mov ds, ax
    mov es, ax
  
    mov dx, xorkey
    mov ah, 09h
    int 21h
  
    mov dx, xorkey1
    mov ah, 0Ah
    int 21h
  
        call TransStr ; funcao conseguir chave de encriptacao
  

 
    mov ah, 02h
    mov dl, 0Ah
    int 21h
    add  dl, 03h
    int 21h   
  
    mov dx, str1
    mov ah, 09h
    int 21h
    
    mov dx, InputStr
    mov ah, 0Ah
    int 21h
  
        call Encrypt ; Encrypts the strings with [xorkey1]
                     
    push si
    

    
    mov ah, 00002h
    mov dl, 0000Ah
    int 21h
    add dl, 00003h
    int 21h
    
    mov ah, 09h
    mov dx, EncryptedText
    int 21h
    
    add ah, 000F9h    
    mov si, InputStr
    add si, 00002h
    xor cx, cx
    mov cl, [InputStr + 1]
    mov bx, hexatable
    xor dx, dx    
    ConvertToASC:
    
    
    mov al, [si]
    mov dl, al
    
    and al, 000F0h
    and dl, 0000Fh
    shr al, 00004h
    
    xlatb
    xchg al, dl
    push ax 
    int 21h
    pop ax
    xlatb
    
    xchg al, dl
    int 21h  
    
    mov dl, 00020h
    int 21h
    
    inc si
    loop ConvertToASC
    pop si
    
    mov ax, 4c00h
    int 21h    
 
 
 
 
    ;funcao de transformacao de caracteres(0 - 255) para seu valor binario

  TransStr:

    xor cx,cx
    mov cl, [xorkey1 + 1] 
  
    mov bx, 1
    push bx ; inicializador
    xor ax,ax  
  
    loop1:
  
        dec cl
        pop bx ;incialmente o incializador, a partir do loop1 p1
        inc bx ;apontador da memoria [xorkey1 +2]
        push bx ; p1, salva o apontador na memoria
  
        push cx  ;p2, salva o contador na memoria para fazer o loop2

        push ax  ;p3 , valores para ir somando: centena, dezena e unidade
        mov al, 01h
        mov dl, 0Ah 
  
        jcxz cx0
    
        loop2:      ; loop da multiplicacao para obter centena, dezena e unidade

            mul dl
  
            loop loop2 
  
        cx0:
  
        mov bl, [xorkey1 + bx]
        add bl, 000D0h  
        mul bl

        pop bx ;p3
        add ax, bx
        pop cx ;p2
  
        mov [xorkey1], al ; valor atual somado aos anteriores
  
  
        cmp cx,0
        jne loop1
        pop bx
  
   ret 
  
    ;Funcao de encriptar a string
  
  Encrypt:
    
    mov bx, [xorkey1] ; chave de encriptacao
    add dx, 02h
    mov di, dx
    mov si, dx
    mov al, 0Dh
  
    mov cx, 0ffffh
    repne scasb
  
    neg cx
  
    dec si
    push cx
    encrypting:
        
        push si
        add si, cx
        mov dl, byte [si]
        xor dx, bx
        mov [si], dl
        pop si
  
        loop encrypting
    pop cx
  ret