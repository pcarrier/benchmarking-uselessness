#!/usr/bin/make -sf

.PHONY: default
default: bench

.PHONY: bin
bin: looprun \
	noop_asm \
	noop_statc \
	noop_dync \
	noop_statf \
	noop_dynf \
	noop_staths \
	noop_dynhs \
	noop_statdiet \
	noop_statmusl \
	noop_dynmusl \
	noop_go \
	noop_ocaml \
	noop_sbcl \
	noop_chicken \
	noop_mono.exe \
	Noop.class

looprun: looprun.c
	gcc -s -O3 -std=c99 -Wall -Wextra -o looprun looprun.c -lrt

noop_statc: noop.c
	gcc -s -O3 -o noop_statc noop.c -static -static-libgcc

noop_dync: noop.c
	gcc -s -O3 -o noop_dync noop.c

noop_statf: noop.f
	gfortran -O3 -s -o noop_statf noop.f -static

noop_dynf: noop.f
	gfortran -O3 -s -o noop_dynf noop.f

noop_staths: noop.hs
	rm noop.hi || true # f things up
	ghc -O3 -o noop_staths noop.hs -optl-static -optl-pthread

noop_dynhs: noop.hs
	rm noop.hi || true # f things up
	ghc -O3 -o noop_dynhs noop.hs -dynamic

noop_statdiet: noop.c
	/opt/diet/bin/diet gcc -O3 -s -o noop_statdiet noop.c -static -static-libgcc

noop_statmusl: noop.c
	/usr/bin/musl-gcc -O3 -s -o noop_statmusl noop.c -static -static-libgcc

noop_dynmusl: noop.c
	/usr/bin/musl-gcc -O3 -s -o noop_dynmusl noop.c

noop_asm: noop.s
	gcc -c noop.s
	gcc -Wl,--build-id=none -s -nostdlib -o noop_asm noop.o

noop_ocaml: noop.ml
	ocamlopt -o noop_ocaml noop.ml
	strip -x noop_ocaml

noop_sbcl: noop.compile.sbcl
	sbcl --load noop.compile.sbcl

noop_go: noop.go
	go build -o noop_go noop.go

noop_chicken: noop.chicken.scm
	csc -O3 -u -o noop_chicken noop.chicken.scm

noop_mono.exe: noop.cs
	gmcs -out:noop_mono.exe noop.cs

Noop.class: Noop.java
	javac Noop.java

.PHONY: clean
clean:
	rm looprun \
	noop.o \
	noop_mono.exe \
	Noop.class \
	noop_asm \
	noop_statc \
	noop_dync \
	noop_statf \
	noop_dynf \
	noop_staths \
	noop_dynhs \
	noop_statdiet \
	noop_statmusl \
	noop_dynmusl \
	noop_ocaml noop.cmi noop.cmo noop.cmx \
	noop_sbcl \
	noop_go \
	noop_chicken \
	|| true

define announce
printf "%-20s" $1:
endef

.PHONY: bench
bench: bin \
       bench_asm \
       bench_statdiet \
       bench_statmusl \
       bench_dynmusl \
       bench_statc \
       bench_dync \
       bench_statf \
       bench_dynf \
       bench_staths \
       bench_dynhs \
       bench_ocaml \
       bench_go \
       bench_lua \
       bench_bb \
       bench_dash \
       bench_mksh \
       bench_rc \
       bench_nawk \
       bench_awk \
       bench_tclsh \
       bench_bash \
       bench_zsh \
       bench_tcsh \
       bench_php \
       bench_perl \
       bench_chicken_c \
       bench_chicken_script \
       bench_guile \
       bench_sbcl_c \
       bench_sbcl_script \
       bench_ruby \
       bench_emacs \
       bench_d8 \
       bench_node \
       bench_py2 \
       bench_py3 \
       bench_avian \
       bench_jamvm \
       bench_java \
       bench_mono

.PHONY: bench_asm
bench_asm: looprun noop_asm
	$(call announce,Assembly)
	./looprun 42 -2    ./noop_asm
	./looprun 42 10000 ./noop_asm

.PHONY: bench_statdiet
bench_statdiet: looprun noop_statdiet
	$(call announce,"C (diet, static)")
	./looprun 42 -2   ./noop_statdiet
	./looprun 42 5000 ./noop_statdiet

.PHONY: bench_statmusl
bench_statmusl: looprun noop_statmusl
	$(call announce,"C (musl, static)")
	./looprun 42 -2   ./noop_statmusl
	./looprun 42 5000 ./noop_statmusl

.PHONY: bench_dynmusl
bench_dynmusl: looprun noop_dynmusl
	$(call announce,"C (musl, dynamic)")
	./looprun 42 -2   ./noop_dynmusl
	./looprun 42 5000 ./noop_dynmusl

.PHONY: bench_statc
bench_statc: looprun noop_statc
	$(call announce,"C (static)")
	./looprun 42 -2   ./noop_statc
	./looprun 42 5000 ./noop_statc

.PHONY: bench_dync
bench_dync: looprun noop_dync
	$(call announce,"C (dynamic)")
	./looprun 42 -2   ./noop_dync
	./looprun 42 3000 ./noop_dync

.PHONY: bench_statf
bench_statf: looprun noop_statf
	$(call announce,"Fortran (static)")
	./looprun 42 -2   ./noop_statf
	./looprun 42 5000 ./noop_statf

.PHONY: bench_dynf
bench_dynf: looprun noop_dynf
	$(call announce,"Fortran (dynamic)")
	./looprun 42 -2   ./noop_dynf
	./looprun 42 2000 ./noop_dynf

.PHONY: bench_staths
bench_staths: looprun noop_staths
	$(call announce,"Haskell (static)")
	./looprun 42 -2   ./noop_staths
	./looprun 42 2000 ./noop_staths

.PHONY: bench_dynhs
bench_dynhs: looprun noop_dynhs
	$(call announce,"Haskell (dynamic)")
	./looprun 42 -2   ./noop_dynhs
	./looprun 42 1000 ./noop_dynhs

.PHONY: bench_bb
bench_bb: looprun
	$(call announce,"BusyBox shell")
	./looprun 42 -2   /bin/busybox sh noop.sh
	./looprun 42 3000 /bin/busybox sh noop.sh

.PHONY: bench_dash
bench_dash: looprun
	$(call announce,dash)
	./looprun 42 -2   /bin/dash noop.sh
	./looprun 42 1000 /bin/dash noop.sh

.PHONY: bench_rc
bench_rc: looprun
	$(call announce,"plan9 rc")
	./looprun 42 -2  /opt/plan9/bin/rc ./noop.sh
	./looprun 42 1000 /opt/plan9/bin/rc ./noop.sh

.PHONY: bench_mksh
bench_mksh: looprun
	$(call announce,"mksh")
	./looprun 42 -2  /bin/mksh ./noop.sh
	./looprun 42 1000 /bin/mksh ./noop.sh

.PHONY: bench_bash
bench_bash: looprun
	$(call announce,Bash)
	./looprun 42 -2  /bin/bash --norc noop.sh
	./looprun 42 500 /bin/bash --norc noop.sh

.PHONY: bench_zsh
bench_zsh: looprun
	$(call announce,Zsh)
	./looprun 42 -2  /bin/zsh --no-rcs noop.sh
	./looprun 42 500 /bin/zsh --no-rcs noop.sh

.PHONY: bench_tcsh
bench_tcsh: looprun
	$(call announce,"tcsh")
	./looprun 42 -2  /bin/tcsh -f ./noop.sh
	./looprun 42 500 /bin/tcsh -f ./noop.sh

.PHONY: bench_tclsh
bench_tclsh: looprun
	$(call announce,"tcl")
	./looprun 42 -2  /usr/bin/tclsh ./noop.sh
	./looprun 42 500 /usr/bin/tclsh ./noop.sh

.PHONY: bench_ocaml
bench_ocaml: looprun noop_ocaml
	$(call announce,"OCaml")
	./looprun 42 -2   ./noop_ocaml
	./looprun 42 1000 ./noop_ocaml

.PHONY: bench_go
bench_go: looprun noop_go
	$(call announce,"Go")
	./looprun 42 -2   ./noop_go
	./looprun 42 1000 ./noop_go

.PHONY: bench_lua
bench_lua: looprun
	$(call announce,lua)
	./looprun 42 -2   /usr/bin/lua ./noop.lua
	./looprun 42 1000 /usr/bin/lua ./noop.lua

.PHONY: bench_nawk
bench_nawk: looprun
	$(call announce,"nawk")
	./looprun 42 -2   /usr/bin/nawk -f noop.awk
	./looprun 42 1000 /usr/bin/nawk -f noop.awk

.PHONY: bench_awk
bench_awk: looprun
	$(call announce,"awk (GNU)")
	./looprun 42 -2  /usr/bin/awk -f noop.awk
	./looprun 42 500 /usr/bin/awk -f noop.awk

.PHONY: bench_perl
bench_perl: looprun
	$(call announce,"Perl 5")
	./looprun 42 -2  /usr/bin/perl noop.pl
	./looprun 42 500 /usr/bin/perl noop.pl

.PHONY: bench_php
bench_php: looprun
	$(call announce,PHP5)
	./looprun 42 -2  /usr/bin/php -n noop.php
	./looprun 42 200 /usr/bin/php -n noop.php

.PHONY: bench_chicken_c
bench_chicken_c: looprun noop_chicken
	$(call announce,"Chicken (compiled)")
	./looprun 42 -2  ./noop_chicken
	./looprun 42 200 ./noop_chicken

.PHONY: bench_chicken_script
bench_chicken_script: looprun
	$(call announce,"Chicken (script)")
	./looprun 42 -2  /usr/bin/csi -s noop.chicken.scm
	./looprun 42 200 /usr/bin/csi -s noop.chicken.scm

.PHONY: bench_guile
bench_guile: looprun
	$(call announce,"guile")
	./looprun 42 -2  /usr/bin/guile noop.guile.scm
	./looprun 42 200 /usr/bin/guile noop.guile.scm

.PHONY: bench_sbcl_c
bench_sbcl_c: looprun noop_sbcl
	$(call announce,"SBCL (compiled)")
	./looprun 42 -2  ./noop_sbcl
	./looprun 42 100 ./noop_sbcl

.PHONY: bench_sbcl_script
bench_sbcl_script: looprun
	$(call announce,"SBCL (script)")
	./looprun 42 -2  /usr/bin/sbcl --script noop.sbcl
	./looprun 42 100 /usr/bin/sbcl --script noop.sbcl

.PHONY: bench_ruby
bench_ruby: looprun
	$(call announce,"MRI 1.9")
	./looprun 42 -2  /usr/bin/ruby noop.sh
	./looprun 42 200 /usr/bin/ruby noop.sh

.PHONY: bench_emacs
bench_emacs: looprun
	$(call announce,Emacs)
	./looprun 42 -2 /usr/bin/emacs -Q --script noop.elisp
	./looprun 42 10 /usr/bin/emacs -Q --script noop.elisp

.PHONY: bench_node
bench_node: looprun
	$(call announce,"Node.JS")
	./looprun 42 -2  /usr/bin/node noop.node.js
	./looprun 42 100 /usr/bin/node noop.node.js

.PHONY: bench_d8
bench_d8: looprun
	$(call announce,"V8")
	./looprun 42 -2  /usr/bin/d8 noop.d8.js
	./looprun 42 100 /usr/bin/d8 noop.d8.js

.PHONY: bench_py2
bench_py2: looprun
	$(call announce,"cpython 2")
	./looprun 42 -2  /usr/bin/python2 noop.py
	./looprun 42 100 /usr/bin/python2 noop.py

.PHONY: bench_py3
bench_py3: looprun
	$(call announce,"cpython 3")
	./looprun 42 -2 /usr/bin/python3 noop.py
	./looprun 42 50 /usr/bin/python3 noop.py

.PHONY: bench_avian
bench_avian: looprun Noop.class
	$(call announce,"Java (avian)")
	./looprun 42 -2   /usr/bin/avian Noop
	./looprun 42 1000 /usr/bin/avian Noop

.PHONY: bench_jamvm
bench_jamvm: looprun Noop.class
	$(call announce,"Java (jamvm)")
	./looprun 42 -2  /usr/bin/jamvm Noop
	./looprun 42 100 /usr/bin/jamvm Noop

.PHONY: bench_java
bench_java: looprun Noop.class
	$(call announce,"Java 7 (Oracle)")
	./looprun 42 -2 /opt/java/bin/java Noop
	./looprun 42 50 /opt/java/bin/java Noop

.PHONY: bench_mono
bench_mono: looprun noop_mono.exe
	$(call announce,"Mono (C#)")
	./looprun 42 -2  /usr/bin/mono ./noop_mono.exe
	./looprun 42 100 /usr/bin/mono ./noop_mono.exe
