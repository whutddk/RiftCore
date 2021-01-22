
  .section .text.init
  .globl _prog_start
_prog_start:

    # csrwi satp,0
    # li  t0,-1
    # csrw  pmpaddr0,t0
    # li  t0,31
    # csrw  pmpcfg0,t0
    # csrwi medeleg,0
    # csrwi mideleg,0
    # li t0, 1
    # slli t0, t0, 31
    # csrw  mtvec,t0
    # csrwi mie, 0
    # csrwi mstatus,0

    li sp, 0x80001000


    # li t1, 0x80000200
    # li t2, -1
    # sd t2, 0(t1)

    # li t1,0x80000000
    # jr t1

    call main

 

  # li s1, DDR_BASE
  # jr s1

   ecall

   