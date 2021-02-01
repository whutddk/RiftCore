

rmdir /s /q .\build
md .\build

@echo Remove Complete

@rem compile .c
riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs ^
-I ^
-c ./dhrystone.c ^
-o ./build/dhrystone.o

riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs ^
-I ./ ^
-c ./syscalls.c ^
-o ./build/syscalls.o

riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imac -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs ^
-I ./ ^
-c ./main.c ^
-o ./build/main.o



@echo C Code Compile Complete


@rem compile .s
riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imc -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs -mcmodel=medany -mexplicit-relocs ^
-I ./ ^
-c ./crt.s ^
-o ./build/crt.o



@echo Asm Code Compile Complete


@rem linker
riscv64-unknown-elf-gcc -Os -ggdb -march=rv64imc -mabi=lp64 -Wall -mcmodel=medany -mexplicit-relocs -nostdlib -nodefaultlibs -nostartfiles ^
-I ./  ^
-T ds.lds ^
./build/crt.o ^
./build/dhrystone.o ./build/syscalls.o ./build/main.o ^
-o dhrystone.elf

@rem objcopy
riscv64-unknown-elf-objcopy -O binary .\dhrystone.elf  ./dhrystone.bin



@rem dump
riscv64-unknown-elf-objdump ^
--disassemble-all ^
--disassemble-zeroes ^
--section=.text ^
--section=.text.startup ^
--section=.text.init ^
--section=.data ^
--section=.bss ^
--section=.rodata ^
dhrystone.elf >dhrystone.dump


riscv64-unknown-elf-objcopy -O verilog .\dhrystone.elf  ./dhrystone.verilog


@pause




