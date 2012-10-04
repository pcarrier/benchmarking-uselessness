#!/usr/bin/make -sf

.PHONY: default
default: bench

.PHONY: bin
bin: looprun \
	noop_asm \
	noop_go \
	noop_statc \
	noop_dync \
	noop_statdiet \
	noop_statmusl \
	noop_dynmusl \
	noop_chicken \
	Noop.class

looprun: looprun.c
	gcc -s -O3 -std=c99 -Wall -Wextra -o looprun looprun.c -lrt

noop_statc: noop.c
	gcc -s -O3 -o noop_statc noop.c -static -static-libgcc

noop_dync: noop.c
	gcc -s -O3 -o noop_dync noop.c

noop_statdiet: noop.c
	/opt/diet/bin/diet gcc -O3 -s -o noop_statdiet noop.c -static -static-libgcc

noop_statmusl: noop.c
	/usr/bin/musl-gcc -O3 -s -o noop_statmusl noop.c -static -static-libgcc

noop_dynmusl: noop.c
	/usr/bin/musl-gcc -O3 -s -o noop_dynmusl noop.c

noop_asm: noop.s
	gcc -c noop.s
	gcc -Wl,--build-id=none -s -nostdlib -o noop_asm noop.o

noop_go: noop.go
	go build -o noop_go noop.go

noop_chicken:
	csc -O3 -u -o noop_chicken noop.scm

Noop.class: Noop.java
	javac Noop.java

.PHONY: clean
clean:
	rm looprun \
	noop.o \
	Noop.class \
	noop_asm \
	noop_statc \
	noop_dync \
	noop_diet \
	noop_statmusl \
	noop_dynmusl \
	noop_go \
	noop_chicken

define announce
printf "%-20s" $1:
endef

.PHONY: bench
bench: bench_asm \
       bench_statdiet \
       bench_statmusl \
       bench_dynmusl \
       bench_statc \
       bench_dync \
       bench_bb \
       bench_dash \
       bench_mksh \
       bench_rc \
       bench_bash \
       bench_zsh \
       bench_tcsh \
       bench_go \
       bench_awk \
       bench_php \
       bench_chicken_c \
       bench_chicken_script \
       bench_ruby \
       bench_emacs \
       bench_d8 \
       bench_node \
       bench_py2 \
       bench_py3 \
       bench_java

bench_asm: looprun noop_asm
	$(call announce,Assembly)
	./looprun 42 -2   ./noop_asm
	./looprun 42 5000 ./noop_asm

bench_statdiet: looprun noop_statdiet
	$(call announce,"C (diet, static)")
	./looprun 42 -2   ./noop_statdiet
	./looprun 42 5000 ./noop_statdiet

bench_statmusl: looprun noop_statmusl
	$(call announce,"C (musl, static)")
	./looprun 42 -2   ./noop_statmusl
	./looprun 42 5000 ./noop_statmusl

bench_dynmusl: looprun noop_dynmusl
	$(call announce,"C (musl, dynamic)")
	./looprun 42 -2   ./noop_dynmusl
	./looprun 42 5000 ./noop_dynmusl

bench_statc: looprun noop_statc
	$(call announce,"C (static)")
	./looprun 42 -2   ./noop_statc
	./looprun 42 5000 ./noop_statc

bench_dync: looprun noop_dync
	$(call announce,"C (dynamic)")
	./looprun 42 -2   ./noop_dync
	./looprun 42 3000 ./noop_dync

bench_bb: looprun
	$(call announce,"BusyBox shell")
	./looprun 42 -2   /bin/busybox sh noop.sh
	./looprun 42 3000 /bin/busybox sh noop.sh

bench_dash: looprun
	$(call announce,dash)
	./looprun 42 -2   /bin/dash noop.sh
	./looprun 42 1000 /bin/dash noop.sh

bench_rc: looprun
	$(call announce,"plan9 rc")
	./looprun 42 -2  /opt/plan9/bin/rc ./noop.sh
	./looprun 42 1000 /opt/plan9/bin/rc ./noop.sh

bench_mksh: looprun
	$(call announce,"mksh")
	./looprun 42 -2  /bin/mksh ./noop.sh
	./looprun 42 1000 /bin/mksh ./noop.sh

bench_bash: looprun
	$(call announce,Bash)
	./looprun 42 -2  /bin/bash --norc noop.sh
	./looprun 42 500 /bin/bash --norc noop.sh

bench_zsh: looprun
	$(call announce,Zsh)
	./looprun 42 -2  /bin/zsh --no-rcs noop.sh
	./looprun 42 500 /bin/zsh --no-rcs noop.sh

bench_tcsh: looprun
	$(call announce,"tcsh")
	./looprun 42 -2  /bin/tcsh -f ./noop.sh
	./looprun 42 500 /bin/tcsh -f ./noop.sh

bench_go: looprun noop_go
	$(call announce,"Go")
	./looprun 42 -2  ./noop_go
	./looprun 42 500 ./noop_go

bench_awk: looprun
	$(call announce,"AWK")
	./looprun 42 -2  /usr/bin/awk -f noop.awk
	./looprun 42 200 /usr/bin/awk -f noop.awk

bench_php: looprun
	$(call announce,PHP5)
	./looprun 42 -2  /usr/bin/php -n noop.php
	./looprun 42 200 /usr/bin/php -n noop.php

bench_chicken_c: looprun noop_chicken
	$(call announce,"Chicken (compiled)")
	./looprun 42 -2  ./noop_chicken
	./looprun 42 200 ./noop_chicken

bench_chicken_script: looprun
	$(call announce,"Chicken (script)")
	./looprun 42 -2  /usr/bin/csi -s noop.scm
	./looprun 42 200 /usr/bin/csi -s noop.scm

bench_ruby: looprun
	$(call announce,"MRI 1.9")
	./looprun 42 -2  /usr/bin/ruby noop.sh
	./looprun 42 200 /usr/bin/ruby noop.sh

bench_emacs: looprun
	$(call announce,Emacs)
	./looprun 42 -2  /usr/bin/emacs --no-site-file --script noop.elisp
	./looprun 42 100 /usr/bin/emacs --no-site-file --script noop.elisp

bench_node: looprun
	$(call announce,"Node.JS")
	./looprun 42 -2  /usr/bin/node noop.node.js
	./looprun 42 100 /usr/bin/node noop.node.js

bench_d8: looprun
	$(call announce,"V8")
	./looprun 42 -2  /usr/bin/d8 noop.d8.js
	./looprun 42 100 /usr/bin/d8 noop.d8.js

bench_py2: looprun
	$(call announce,"cpython 2")
	./looprun 42 -2  /usr/bin/python2 noop.py
	./looprun 42 100 /usr/bin/python2 noop.py

bench_py3: looprun
	$(call announce,"cpython 3")
	./looprun 42 -2  /usr/bin/python3 noop.py
	./looprun 42 50 /usr/bin/python3 noop.py

bench_java: looprun Noop.class
	$(call announce,"Java 7 (Oracle)")
	./looprun 42 -2  /opt/java/bin/java Noop
	./looprun 42 50 /opt/java/bin/java Noop
