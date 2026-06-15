    .section .text
    .globl alu_lfsr_test

# a0 = iterations
# a1 = seed (must be non-zero)
# return a0 = checksum

alu_lfsr_test:
    mv      t0, a0          # loop counter
    mv      t1, a1          # LFSR state
    li      t2, 0           # checksum

loop:
    beqz    t0, done

    # -----------------------------
    # LFSR 64-bit
    # -----------------------------
    srli    t3, t1, 63
    srli    t4, t1, 62
    srli    t5, t1, 60
    srli    t6, t1, 59

    xor     t3, t3, t4
    xor     t3, t3, t5
    xor     t3, t3, t6
    andi    t3, t3, 1

    slli    t1, t1, 1
    or      t1, t1, t3

    # -----------------------------
    # ALU register ops
    # -----------------------------
    add     t4, t1, t2
    sub     t5, t4, t1
    xor     t6, t5, t4
    and     t3, t6, t1
    or      t3, t3, t5

    slli    t4, t3, 3
    srli    t5, t4, 2
    sltu    t6, t5, t4

    # -----------------------------
    # ALU immediate ops
    # -----------------------------
    addi    t3, t1, 123
    xori    t4, t3, 0x55
    andi    t5, t4, 0xFF
    ori     t6, t5, 0xA5

    slli    t3, t6, 4
    srli    t4, t3, 1
    srai    t5, t3, 3

    slti    t6, t4, 100
    sltiu   t3, t5, 200

    # -----------------------------
    # Accumulatore
    # -----------------------------
    add     t2, t2, t6
    xor     t2, t2, t4
    add     t2, t2, t3
    xor     t2, t2, t5

    addi    t0, t0, -1
    j       loop

done:
    mv      a0, t2
    ret