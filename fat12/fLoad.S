ReadSector:
    push ebp
    mov ebp, esp
    sub esp, 2
    mov [ebp-2], cl
    push bx
    mov bl, [BPB_SecPerTrk]
    div bl
    inc ah
    mov al, ah
    shr al, 1
    mov ch, al
    and dh, 1
    pop bx
    mov dl, [BS_DrvNum]

GoOnReading:
    mov ah, 2
    mov al, [ebp-2]
    int 0x13
    jc GoOnReading
    add esp, 2
    pop ebp
    ret
