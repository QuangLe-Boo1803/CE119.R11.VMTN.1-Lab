# Doi dong 'j' ben duoi thanh tn2_main hoac tn3_main de chon phan chay
.text
main:
    j    tn3_main

# ============================================================
# TN2 - Thu tuc va mang: thong ke diem
# ============================================================
.data
tn2_S:      .word 2, 10, 4, 5, 9, 1, 3, 9, 2, 5, 0, 10   # T1: mang ca nhan (d = 7)
tn2_T2:     .word 10                                      # T2: {10}
tn2_T3:     .word 4, 4, 4, 4, 4                           # T3: {4,4,4,4,4}
tn2_tests:  .word tn2_S, 12, tn2_T2, 1, tn2_T3, 5         # bang (dia chi mang, n)
grade_tab:  .byte 0,0,0,0, 1,1,1, 2,2, 3,3                # diem 0..10 -> nhom
            .align 2
hist:       .word 0, 0, 0, 0
s_min:      .asciiz "min="
s_max:      .asciiz " max="

.text
tn2_main:
    la   $s0, tn2_tests         # con tro bang test
    li   $s1, 3                 # so bo du lieu
tn2_next:
    lw   $a0, 0($s0)            # dia chi mang
    lw   $a1, 4($s0)            # n
    move $s2, $a0               # cat lai (a0, a1 se bi thu tuc doi)
    move $s3, $a1
    jal  stats
    move $s4, $v0               # min
    move $s5, $v1               # max

    la   $t0, hist              # xoa hist ve 0 truoc moi bo
    sw   $zero, 0($t0)
    sw   $zero, 4($t0)
    sw   $zero, 8($t0)
    sw   $zero, 12($t0)

    move $a0, $s2
    move $a1, $s3
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram

    # in "min=<..> max=<..>"
    la   $a0, s_min
    li   $v0, 4
    syscall
    move $a0, $s4
    li   $v0, 1
    syscall
    la   $a0, s_max
    li   $v0, 4
    syscall
    move $a0, $s5
    li   $v0, 1
    syscall
    li   $a0, 10
    li   $v0, 11
    syscall

    # in "g0=<..> g1=<..> g2=<..> g3=<..>"
    la   $s6, hist
    li   $s7, 0
tn2_pg:
    beq  $s7, $zero, tn2_nospace
    li   $a0, 32                # ' '
    li   $v0, 11
    syscall
tn2_nospace:
    li   $a0, 103               # 'g'
    li   $v0, 11
    syscall
    move $a0, $s7
    li   $v0, 1
    syscall
    li   $a0, 61                # '='
    li   $v0, 11
    syscall
    lw   $a0, 0($s6)
    li   $v0, 1
    syscall
    addi $s6, $s6, 4
    addi $s7, $s7, 1
    slti $t0, $s7, 4
    bne  $t0, $zero, tn2_pg
    li   $a0, 10
    li   $v0, 11
    syscall

    addi $s0, $s0, 8
    addi $s1, $s1, -1
    bne  $s1, $zero, tn2_next

    li   $v0, 10              
    syscall

# stats: a0 = dia chi mang word, a1 = n (n >= 1)
#        v0 = min, v1 = max. Thu tuc la, mot luot duyet.
stats:
    lw   $v0, 0($a0)            # min = max = phan tu dau
    move $v1, $v0
    addi $a0, $a0, 4
    addi $a1, $a1, -1
st_loop:
    beq  $a1, $zero, st_done
    lw   $t0, 0($a0)
    slt  $t1, $t0, $v0          # t0 < min ?
    beq  $t1, $zero, st_nomin
    move $v0, $t0
st_nomin:
    slt  $t1, $v1, $t0          # max < t0 ?
    beq  $t1, $zero, st_nomax
    move $v1, $t0
st_nomax:
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    st_loop
st_done:
    jr   $ra

# histogram: a0 = dia chi mang diem (word), a1 = n,
#            a2 = dia chi grade_tab (byte), a3 = dia chi hist (word)
# Voi moi diem s: hist[grade_tab[s]]++. Thu tuc la.
histogram:
hg_loop:
    beq  $a1, $zero, hg_done
    lw   $t0, 0($a0)            # t0 = s
    addu $t1, $a2, $t0          # dia chi grade_tab + s (mang byte: offset = s)
    lbu  $t1, 0($t1)            # t1 = nhom g
    sll  $t1, $t1, 2            # g * 4 (mang word)
    addu $t1, $a3, $t1          # dia chi hist + 4g
    lw   $t2, 0($t1)
    addi $t2, $t2, 1
    sw   $t2, 0($t1)
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    hg_loop
hg_done:
    jr   $ra

# ============================================================
# TN3 - Ngan xep: kiem tra ngoac can bang
# ============================================================
.data
c1:  .asciiz "(a+b)*[c-{d/e}]"
c2:  .asciiz "f(x[i]{j}))"
c3:  .asciiz "{[(]}}"
c4:  .asciiz "((a)"
c5:  .asciiz ""
c6:  .asciiz "no brackets here"
c7:  .asciiz "]"
c8:  .asciiz "([)]"
cP:  .asciiz "([{([{([{()}])}])}])"     # k = d + 3 = 10 cap long nhau
tn3_tab:   .word c1, c2, c3, c4, c5, c6, c7, c8, cP
t_arrow:   .asciiz " -> ("
t_comma:   .asciiz ", "
t_close:   .asciiz ")\n"

.text
tn3_main:
    la   $s0, tn3_tab
    li   $s1, 9                 # so chuoi
tn3_next:
    lw   $a0, 0($s0)
    move $s2, $a0               # cat con tro chuoi de in
    jal  check_brackets
    move $s3, $v0
    move $s4, $v1

    move $a0, $s2               # in chuoi
    li   $v0, 4
    syscall
    la   $a0, t_arrow
    li   $v0, 4
    syscall
    move $a0, $s3               # in v0
    li   $v0, 1
    syscall
    la   $a0, t_comma
    li   $v0, 4
    syscall
    move $a0, $s4               # in v1
    li   $v0, 1
    syscall
    la   $a0, t_close
    li   $v0, 4
    syscall

    addi $s0, $s0, 4
    addi $s1, $s1, -1
    bne  $s1, $zero, tn3_next

    li   $v0, 10                # thoat TRUOC doan ma thu tuc
    syscall

# check_brackets: a0 = dia chi chuoi .asciiz
#   v0 = vi tri (tu 1), v1 = ma loi (0 ok, 1 sai loai, 2 dong khi rong, 3 con mo)
# Dung chinh $sp lam ngan xep, moi phan tu 1 word. Thu tuc la.
# Moi duong thoat deu qua cb_exit de khoi phuc $sp.
check_brackets:
    move $t2, $sp               # cat $sp luc vao (day ngan xep)
    move $t0, $a0               # con tro ky tu
    li   $t1, 0                 # vi tri
cb_loop:
    lb   $t3, 0($t0)
    beq  $t3, $zero, cb_end
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    li   $t4, 40                # '('
    beq  $t3, $t4, cb_push
    li   $t4, 91                # '['
    beq  $t3, $t4, cb_push
    li   $t4, 123               # '{'
    beq  $t3, $t4, cb_push
    li   $t4, 41                # ')'
    li   $t5, 40                # ngoac mo tuong ung '('
    beq  $t3, $t4, cb_close
    li   $t4, 93                # ']'
    li   $t5, 91
    beq  $t3, $t4, cb_close
    li   $t4, 125               # '}'
    li   $t5, 123
    beq  $t3, $t4, cb_close
    j    cb_loop                # ky tu khac: bo qua
cb_push:
    addi $sp, $sp, -4           # push: giam sp truoc, ghi sau
    sw   $t3, 0($sp)
    j    cb_loop
cb_close:
    beq  $sp, $t2, cb_err2      # ngan xep rong
    lw   $t6, 0($sp)            # pop: doc truoc
    bne  $t6, $t5, cb_err1      # khac loai
    addi $sp, $sp, 4            # roi moi tang sp
    j    cb_loop
cb_end:
    beq  $sp, $t2, cb_ok
    addi $v0, $t1, 1            # con ngoac mo: do dai + 1
    li   $v1, 3
    j    cb_exit
cb_ok:
    li   $v0, 0
    li   $v1, 0
    j    cb_exit
cb_err1:
    move $v0, $t1
    li   $v1, 1
    j    cb_exit
cb_err2:
    move $v0, $t1
    li   $v1, 2
cb_exit:
    move $sp, $t2               # khoi phuc sp tren moi duong thoat
    jr   $ra
