.intel_syntax noprefix

.code16

# Floppy header of FAT12 
    jmp LABEL_START
    nop
BS_OEMName:         .ascii  "jup9020 "      # OEM String, 8 bytes required
BPB_BytsPerSec:     .2byte  512             # Bytes per sector
BPB_SecPerCluster:  .byte   1               # Sector per cluster
BPB_ResvSecCnt:     .2byte  1               # Reserved sector count
BPB_NumFATs:        .byte   2               # Number of FATs
BPB_RootEntCnt:     .2byte  224             # Root entries count
BPB_TotSec16:       .2byte  2880            # Total sector number
BPB_Media:          .byte   0xf0            # Media descriptor
BPB_FATSz16:        .2byte  9               # FAT size (sectors)
BPB_SecPerTrk:      .2byte  18              # Sector per track
BPB_Numheads:       .2byte  2               # Number of magnetic heads
BPB_HiddSec:        .4byte  0               # Number of hidden sectors
BPB_TotSec32:       .4byte  0               # If Totsec 16 equal 0, this works
BS_DrvNum:          .byte   0               # Driver number of imterrupt 13
Bs_Reserved1:       .byte   0               # Reserved
BS_BootSig:         .byte   0x29            # Boot signal
BS_VolId:           .4byte  0               # Volume ID
BS_VolLab:          .ascii  "jOs 0.01   "   # Volume label, 11 bytes required
BS_FileSysType:     .ascii  "FAT12   "      # File system type, 8 bytes required

# Initial registers
LABEL_START:
    # Reset floppy
    xor     ah, ah
    xor     dl, dl
    int     0x13

    movw    [wSectorNo], SecNoOfRootDir

LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
    cmpw    [wRootDirSizeForLoop], 0
    jz      LABEL_NO_LOADERBIN
    decw    [wRootDirSizeForLoop]
    mov     ax, BaseOfLoader
    mov     ax, [wSectorNo]
    mov     cl, 1
    call    ReadSector
    mov     si, LoaderFileName
    mov     di, OffsetOfLoader
    cld
    mov     dx, 0x10

LABEL_SEARCH_FOR_LOADERBIN:
    cmp     cx, 0
    jz      LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
    dec     dx
    mov     cx, 11
    
LABEL_CMP_FILENAME:
    cmp     cx, 0
    jz      LABEL_FILENAME_FOUND
    dec     cx
    lodsb
    cmp     al, ex:[di]
    jz      LABEL_GO_ON
    jmp     LABEL_DIFFERENT

LABEL_GO_ON:
    inc     dl
    jmp     LABEL_CMP_FILENAME

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
    addw    [wSectorNo], 1
    jmp     LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_LOADERBIN:
    mov     dh, 2
    call    dispStr
    jmp     .   #   infinite loop

LABEL_FILENAME_FOUND:
    mov     ax, RootDirSectors
    and     di, 0xffe0
    add     di, 0x1a
    mov     cx, es:[di]
    push    cx
    add     cx, ax
    add     cx, DeltaSecNo
    mov     ax, BaseOfLoader
    mov     es, ax
    mov     bx, OffsetOfLoader
    mov     ax, cx

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

.org 510
# end
.word 0xaa55 # end mark
