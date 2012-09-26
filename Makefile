#!/usr/bin/make -sf

.PHONY: default
default: bench

.PHONY: compiled
compiled: looprun noop_asm noop_c noop_chicken Noop.class

looprun: looprun.c
	gcc -std=c99 -o looprun looprun.c -lrt

noop_c: noop.c
	gcc -O3 -o noop_c noop.c

noop_asm: noop.s
	gcc -c noop.s
	gcc -s -nostdlib -o noop_asm noop.o

noop_chicken:
	csc -O3 -o noop_chicken empty

Noop.class: Noop.java
	javac Noop.java

.PHONY: clean
clean:
	rm looprun noop.o Noop.class noop_asm noop_c noop_chicken

define announce
printf "%-20s" $1:
endef

.PHONY: bench
bench: bench_asm \
       bench_c \
       bench_bb \
       bench_chicken_c \
       bench_zsh \
       bench_bash \
       bench_chicken_script \
       bench_ruby \
       bench_emacs \
       bench_py2 \
       bench_py3 \
       bench_java

bench_asm: looprun noop_asm
	$(call announce,Assembly)
	./looprun -2 ./noop_asm
	./looprun 20000 ./noop_asm

bench_c: looprun noop_c
	$(call announce,C)
	./looprun -2 ./noop_c
	./looprun 5000 ./noop_c

bench_bb: looprun
	$(call announce,"BusyBox shell")
	./looprun -2 /bin/busybox sh empty
	./looprun 3000 /bin/busybox sh empty

bench_bash: looprun
	$(call announce,Bash)
	./looprun -2 /bin/bash --norc empty
	./looprun 500 /bin/bash --norc empty

bench_chicken_c: looprun noop_chicken
	$(call announce,"Chicken (compiled)")
	./looprun -2 ./noop_chicken
	./looprun 500 ./noop_chicken

bench_chicken_script: looprun
	$(call announce,"Chicken (script)")
	./looprun -2 /usr/bin/csi -s empty
	./looprun 500 /usr/bin/csi -s empty

bench_zsh: looprun
	$(call announce,Zsh)
	./looprun -2 /bin/zsh --no-rcs empty
	./looprun 500 /bin/zsh --no-rcs empty

bench_ruby: looprun
	$(call announce,"MRI 1.9")
	./looprun -2 /usr/bin/ruby empty
	./looprun 500 /usr/bin/ruby empty

bench_emacs: looprun
	$(call announce,Emacs)
	./looprun -2 /usr/bin/emacs --no-site-file --script empty
	./looprun 100 /usr/bin/emacs --no-site-file --script empty

bench_py2: looprun
	$(call announce,"cpython 2")
	./looprun -2 /usr/bin/python2 empty
	./looprun 100 /usr/bin/python2 empty

bench_py3: looprun
	$(call announce,"cpython 3")
	./looprun -2 /usr/bin/python3 empty
	./looprun 100 /usr/bin/python3 empty

bench_java: looprun
	$(call announce,"Java 7 (Oracle)")
	./looprun -2 /opt/java/bin/java Noop
	./looprun 100 /opt/java/bin/java Noop
