# =====================================================================
# CE119 - Lab 02 (Phan mo rong, chi bo T1): MANG, CHUOI, THU TUC VA NGAN XEP            (MARS 4.5)
# Ho ten : Nguyen Hai Dang                MSSV : 25520239
# d = 9 (chu so cuoi cua MSSV)  ->  S[i] = (A0[i] + 9) mod 11 ;  k = d + 3 = 12
# =====================================================================
        .data
S:          .word 4, 1, 6, 7, 0, 3, 5, 0, 4, 7, 2, 1   # T1: mang ca nhan (n = 12)
T2:         .word 10                                    # T2: {10} (n = 1)
T3:         .word 4, 4, 4, 4, 4                         # T3: {4,4,4,4,4} (n = 5)
grade_tab:  .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3       # diem s (0..10) -> nhom
            .align 2
hist:       .word 0, 0, 0, 0                            # so sinh vien tung nhom
ds_ptr:     .word S, T2, T3                             # dia chi 3 bo du lieu
ds_len:     .word 12, 1, 5                              # do dai 3 bo du lieu
s_hdr1:     .asciiz "--- Bo du lieu T"
s_hdr2:     .asciiz " ---\n"
s_min:      .asciiz "min="
s_max:      .asciiz " max="

        .text
        .globl main
main:
        move  $s7, $sp               # nho $sp ban dau, kiem tra can bang o cuoi
        li    $s0, 0                 # s0 = chi so bo du lieu (0 = T1, 1 = T2, 2 = T3)
ds_loop:
        slti  $t0, $s0, 1
        beq   $t0, $zero, ds_done
        la    $t0, hist              # xoa hist (4 word) truoc moi bo du lieu
        sw    $zero, 0($t0)
        sw    $zero, 4($t0)
        sw    $zero, 8($t0)
        sw    $zero, 12($t0)
        la    $a0, s_hdr1            # tieu de bo du lieu
        li    $v0, 4
        syscall
        addi  $a0, $s0, 1
        li    $v0, 1
        syscall
        la    $a0, s_hdr2
        li    $v0, 4
        syscall
        sll   $t1, $s0, 2            # nap tham so: s1 = dia chi mang, s2 = n
        la    $t2, ds_ptr
        add   $t2, $t2, $t1
        lw    $s1, 0($t2)
        la    $t2, ds_len
        add   $t2, $t2, $t1
        lw    $s2, 0($t2)
        move  $a0, $s1               # goi stats
        move  $a1, $s2
        jal   stats
        move  $s3, $v0               # s3 = min
        move  $s4, $v1               # s4 = max
        move  $a0, $s1               # goi histogram
        move  $a1, $s2
        la    $a2, grade_tab
        la    $a3, hist
        jal   histogram
        la    $a0, s_min             # dong 1: min=<..> max=<..>
        li    $v0, 4
        syscall
        move  $a0, $s3
        li    $v0, 1
        syscall
        la    $a0, s_max
        li    $v0, 4
        syscall
        move  $a0, $s4
        li    $v0, 1
        syscall
        li    $a0, 10
        li    $v0, 11
        syscall
        la    $s5, hist              # dong 2: g0=<..> g1=<..> g2=<..> g3=<..>
        li    $s6, 0
pg_loop:
        li    $a0, 103               # 'g'
        li    $v0, 11
        syscall
        move  $a0, $s6
        li    $v0, 1
        syscall
        li    $a0, 61                # '='
        li    $v0, 11
        syscall
        lw    $a0, 0($s5)
        li    $v0, 1
        syscall
        addi  $s5, $s5, 4
        addi  $s6, $s6, 1
        li    $t0, 4
        beq   $s6, $t0, pg_end
        li    $a0, 32                # ' '
        li    $v0, 11
        syscall
        j     pg_loop
pg_end:
        li    $a0, 10
        li    $v0, 11
        syscall
        la    $a0, hist              # phan mo rong: ve bieu do
        li    $a1, 4
        jal   draw_hist
        addi  $s0, $s0, 1
        j     ds_loop
ds_done:

        li    $v0, 10                # thoat TRUOC doan ma thu tuc
        syscall

# ---------------------------------------------------------------------
# stats: tim gia tri nho nhat va lon nhat cua mang word (mot luot duyet)
# Tham so : $a0 = dia chi mang word, $a1 = n (n >= 1)
# Tra ve  : $v0 = min, $v1 = max
# Thanh ghi dung: $v0, $v1 (ket qua); $a0, $a1 (bi thay doi); $t0, $t1 (tam)
# La thu tuc la (khong jal), khong ghi bo nho.
# ---------------------------------------------------------------------
stats:
        lw    $v0, 0($a0)            # min = phan tu dau
        move  $v1, $v0               # max = phan tu dau
        addi  $a0, $a0, 4            # tro sang phan tu thu hai
        addi  $a1, $a1, -1           # con n-1 phan tu can duyet
st_loop:
        beq   $a1, $zero, st_done
        lw    $t0, 0($a0)            # t0 = phan tu hien tai
        slt   $t1, $t0, $v0          # t1 = (t0 < min)
        beq   $t1, $zero, st_max
        move  $v0, $t0               # cap nhat min
st_max:
        slt   $t1, $v1, $t0          # t1 = (max < t0)
        beq   $t1, $zero, st_next
        move  $v1, $t0               # cap nhat max
st_next:
        addi  $a0, $a0, 4
        addi  $a1, $a1, -1
        j     st_loop
st_done:
        jr    $ra

# ---------------------------------------------------------------------
# histogram: dem so diem trong tung nhom xep loai, hist[grade_tab[s]]++
# Tham so : $a0 = dia chi mang diem (word), $a1 = n,
#           $a2 = dia chi grade_tab (byte), $a3 = dia chi hist (word)
# Tra ve  : khong
# Thanh ghi dung: $a0, $a1 (bi thay doi); $t0..$t4 (tam)
# La thu tuc la. Tra bang bang lbu, khong so sanh diem voi nguong.
# ---------------------------------------------------------------------
histogram:
hg_loop:
        beq   $a1, $zero, hg_done
        lw    $t0, 0($a0)            # t0 = s (diem)
        add   $t1, $a2, $t0          # dia chi grade_tab[s] (phan tu 1 byte: offset = s)
        lbu   $t2, 0($t1)            # t2 = nhom g
        sll   $t2, $t2, 2            # offset byte = g * 4 (hist la mang word)
        add   $t3, $a3, $t2          # dia chi hist[g]
        lw    $t4, 0($t3)
        addi  $t4, $t4, 1
        sw    $t4, 0($t3)            # hist[g] = hist[g] + 1
        addi  $a0, $a0, 4            # sang diem ke tiep (con tro tang 4 byte)
        addi  $a1, $a1, -1
        j     hg_loop
hg_done:
        jr    $ra

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

# ---------------------------------------------------------------------
# draw_hist: ve bieu do cot ngang, moi nhom 1 dong "g<i>: |||..."
# Tham so : $a0 = dia chi mang hist, $a1 = so nhom (4)
# Tra ve  : khong
# Thanh ghi dung: $t0 = con tro hist, $t1 = so nhom con lai, $t2 = chi so nhom,
#                 $t3 = bo dem ky tu '|' ; $a0, $v0 dung cho syscall
# La thu tuc la. Khong giu con tro hist trong $a0 vi syscall ghi de $a0.
# ---------------------------------------------------------------------
draw_hist:
        move  $t0, $a0
        move  $t1, $a1
        li    $t2, 0
dh_row:
        beq   $t1, $zero, dh_done
        li    $a0, 103               # 'g'
        li    $v0, 11
        syscall
        addi  $a0, $t2, 48           # '0' + chi so nhom
        li    $v0, 11
        syscall
        li    $a0, 58                # ':'
        li    $v0, 11
        syscall
        li    $a0, 32                # ' '
        li    $v0, 11
        syscall
        lw    $t3, 0($t0)            # so sinh vien cua nhom
dh_bar:
        beq   $t3, $zero, dh_nl
        li    $a0, 124               # '|'
        li    $v0, 11
        syscall
        addi  $t3, $t3, -1
        j     dh_bar
dh_nl:
        li    $a0, 10                # xuong dong
        li    $v0, 11
        syscall
        addi  $t0, $t0, 4
        addi  $t2, $t2, 1
        addi  $t1, $t1, -1
        j     dh_row
dh_done:
        jr    $ra
