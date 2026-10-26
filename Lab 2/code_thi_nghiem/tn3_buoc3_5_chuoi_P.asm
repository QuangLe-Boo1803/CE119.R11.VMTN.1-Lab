# =====================================================================
# CE119 - Lab 02 (Buoc 3.5, chuoi P): MANG, CHUOI, THU TUC VA NGAN XEP            (MARS 4.5)
# Ho ten : Nguyen Hai Dang                MSSV : 25520239
# d = 9 (chu so cuoi cua MSSV)  ->  S[i] = (A0[i] + 9) mod 11 ;  k = d + 3 = 12
# =====================================================================
        .data
brP:        .asciiz "([{([{([{([{}])}])}])}])"          # chuoi P: k = 12 cap long nhau
s_pre:      .asciiz "check_brackets(P) -> ($v0, $v1) = ("
s_comma:    .asciiz ", "
s_end:      .asciiz ")\n"

        .text
        .globl main
main:
        la    $a0, brP
        jal   check_brackets         # sau lenh nay $sp phai bang gia tri luc truoc jal
        move  $s0, $v0
        move  $s1, $v1
        la    $a0, s_pre
        li    $v0, 4
        syscall
        move  $a0, $s0
        li    $v0, 1
        syscall
        la    $a0, s_comma
        li    $v0, 4
        syscall
        move  $a0, $s1
        li    $v0, 1
        syscall
        la    $a0, s_end
        li    $v0, 4
        syscall
        li    $v0, 10
        syscall

# ---------------------------------------------------------------------
# check_brackets: kiem tra cap ngoac ( ) [ ] { } bang ngan xep
# Tham so : $a0 = dia chi chuoi .asciiz
# Tra ve  : $v0 = vi tri (dem tu 1), $v1 = ma loi
#           0 = hop le (v0 = 0) ; 1 = dong khac loai (v0 = vi tri ngoac dong)
#           2 = dong khi ngan xep rong (v0 = vi tri) ; 3 = con ngoac mo (v0 = do dai + 1)
# Thanh ghi dung: $t0 = vi tri hien tai, $t1 = ky tu, $t2 = $sp luc vao (day ngan xep),
#                 $t3 = hang so ky tu, $t4 = ngoac mo tuong ung, $t5 = phan tu pop
#                 $a0 (bi thay doi: con tro chuoi), $v0, $v1
# Ngan xep: moi phan tu 1 word (ky tu ngoac mo). La thu tuc la.
# $sp tro ve dung gia tri luc vao tren MOI duong thoat (qua nhan cb_exit).
# ASCII: ( = 40, ) = 41, [ = 91, ] = 93, { = 123, } = 125
# ---------------------------------------------------------------------
check_brackets:
        move  $t2, $sp               # t2 = $sp luc vao: vua la day ngan xep, vua de khoi phuc
        li    $t0, 0                 # vi tri = 0
cb_loop:
        lbu   $t1, 0($a0)            # doc ky tu hien tai
        beq   $t1, $zero, cb_end     # gap NUL -> het chuoi
        addi  $t0, $t0, 1            # vi tri tinh tu 1
        addi  $a0, $a0, 1            # sang ky tu ke tiep
        li    $t3, 40                # '('
        beq   $t1, $t3, cb_push
        li    $t3, 91                # '['
        beq   $t1, $t3, cb_push
        li    $t3, 123               # '{'
        beq   $t1, $t3, cb_push
        li    $t3, 41                # ')'
        li    $t4, 40                # ngoac mo phai la '('
        beq   $t1, $t3, cb_close
        li    $t3, 93                # ']'
        li    $t4, 91                # ngoac mo phai la '['
        beq   $t1, $t3, cb_close
        li    $t3, 125               # '}'
        li    $t4, 123               # ngoac mo phai la '{'
        beq   $t1, $t3, cb_close
        j     cb_loop                # ky tu khac: bo qua
cb_push:
        addi  $sp, $sp, -4           # push: dich $sp truoc ...
        sw    $t1, 0($sp)            # ... roi ghi ngoac mo
        j     cb_loop
cb_close:                            # <<< BREAKPOINT (Buoc 3.5): lenh dau tien xu ly ngoac dong
        beq   $sp, $t2, cb_err_empty # ngan xep rong -> loi 2
        lw    $t5, 0($sp)            # pop: doc dinh truoc ...
        addi  $sp, $sp, 4            # ... roi dich $sp len
        bne   $t5, $t4, cb_err_type  # khac loai -> loi 1
        j     cb_loop
cb_err_type:
        move  $v0, $t0               # vi tri ngoac dong
        li    $v1, 1
        j     cb_exit
cb_err_empty:
        move  $v0, $t0               # vi tri ngoac dong
        li    $v1, 2
        j     cb_exit
cb_end:
        bne   $sp, $t2, cb_err_open  # het chuoi ma ngan xep con phan tu -> loi 3
        move  $v0, $zero             # hop le
        move  $v1, $zero
        j     cb_exit
cb_err_open:
        addi  $v0, $t0, 1            # do dai chuoi + 1
        li    $v1, 3
cb_exit:
        move  $sp, $t2               # khoi phuc $sp (moi duong thoat deu di qua day)
        jr    $ra

