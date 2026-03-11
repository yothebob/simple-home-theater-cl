#!/usr/bin/env -S sbcl --script

(load "~/.sbclrc")
(asdf:load-system "simple-home-theater-cl")
(simple-home-theater-cl::main)
