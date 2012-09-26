#!/usr/bin/make -sf

.PHONY: default
default: bench

.PHONY: bin
bin: looprun noop_asm noop_go noop_statc noop_dync noop_diet_statc noop_diet_dync noop_chicken Noop.class

looprun: looprun.c
	gcc -O3 -s -std=c99 -o looprun looprun.c -lrt

noop_dync: noop.c
	gcc -O3 -s -o noop_dync noop.c

noop_statc: noop.c
	gcc -O3 -s -o noop_statc noop.c -static -static-libgcc

# Somehow broken
noop_diet_dync: noop.c
	/opt/diet/bin/diet-dyn gcc -O3 -s -o noop_diet_dync noop.c

noop_diet_statc: noop.c
	/opt/diet/bin/diet gcc -O3 -s -o noop_diet_statc noop.c

noop_asm: noop.s
	gcc -c noop.s
	gcc -Wl,--build-id=none -s -nostdlib -o noop_asm noop.o

noop_go: noop.go
	go build -o noop_go noop.go

noop_chicken:
	csc -O3 -u -o noop_chicken empty

Noop.class: Noop.java
	javac Noop.java

.PHONY: clean
clean:
	rm looprun noop.o Noop.class noop_asm noop_statc noop_dync noop_diet_statc noop_diet_dync noop_go noop_chicken

define announce
printf "%-20s" $1:
endef

.PHONY: bench
bench: bench_asm \
       bench_diet_statc \
       bench_statc \
       bench_dync \
       bench_go_c \
       bench_bb \
       bench_chicken_c \
       bench_chicken_script \
       bench_zsh \
       bench_bash \
       bench_go_script \
       bench_ruby \
       bench_emacs \
       bench_node \
       bench_d8 \
       bench_py2 \
       bench_py3 \
       bench_java

bench_asm: looprun noop_asm
	$(call announce,Assembly)
	./looprun -2    ./noop_asm
	./looprun 10000 ./noop_asm

bench_go_c: looprun noop_go
	$(call announce,"Go (compiled)")
	./looprun -2   ./noop_go
	./looprun 1000 ./noop_go

bench_go_script: looprun
	$(call announce,"Go (script)")
	./looprun -2  /usr/bin/go run noop.go
	./looprun 100 /usr/bin/go run noop.go

bench_diet_statc: looprun noop_diet_statc
	$(call announce,"C (diet, static)")
	./looprun -2   ./noop_diet_statc
	./looprun 5000 ./noop_diet_statc

bench_diet_dync: looprun noop_diet_dync
	$(call announce,"C (diet, dynamic)")
	./looprun -2   ./noop_diet_dync
	./looprun 5000 ./noop_diet_dync

bench_statc: looprun noop_statc
	$(call announce,"C (static)")
	./looprun -2   ./noop_statc
	./looprun 5000 ./noop_statc

bench_dync: looprun noop_dync
	$(call announce,"C (dynamic)")
	./looprun -2   ./noop_dync
	./looprun 5000 ./noop_dync

bench_bb: looprun
	$(call announce,"BusyBox shell")
	./looprun -2   /bin/busybox sh empty
	./looprun 3000 /bin/busybox sh empty

bench_bash: looprun
	$(call announce,Bash)
	./looprun -2  /bin/bash --norc empty
	./looprun 500 /bin/bash --norc empty

bench_chicken_c: looprun noop_chicken
	$(call announce,"Chicken (compiled)")
	./looprun -2  ./noop_chicken
	./looprun 500 ./noop_chicken

bench_chicken_script: looprun
	$(call announce,"Chicken (script)")
	./looprun -2  /usr/bin/csi -s empty
	./looprun 500 /usr/bin/csi -s empty

bench_zsh: looprun
	$(call announce,Zsh)
	./looprun -2  /bin/zsh --no-rcs empty
	./looprun 500 /bin/zsh --no-rcs empty

bench_ruby: looprun
	$(call announce,"MRI 1.9")
	./looprun -2  /usr/bin/ruby empty
	./looprun 500 /usr/bin/ruby empty

bench_emacs: looprun
	$(call announce,Emacs)
	./looprun -2  /usr/bin/emacs --no-site-file --script empty
	./looprun 100 /usr/bin/emacs --no-site-file --script empty

bench_node: looprun
	$(call announce,"Node.JS")
	./looprun -2  /usr/bin/node empty
	./looprun 100 /usr/bin/node empty

bench_d8: looprun
	$(call announce,"V8")
	./looprun -2  /usr/bin/d8 empty
	./looprun 100 /usr/bin/d8 empty

bench_py2: looprun
	$(call announce,"cpython 2")
	./looprun -2  /usr/bin/python2 empty
	./looprun 100 /usr/bin/python2 empty

bench_py3: looprun
	$(call announce,"cpython 3")
	./looprun -2  /usr/bin/python3 empty
	./looprun 100 /usr/bin/python3 empty

bench_java: looprun Noop.class
	$(call announce,"Java 7 (Oracle)")
	./looprun -2  /opt/java/bin/java Noop
	./looprun 100 /opt/java/bin/java Noop
