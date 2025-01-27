#!/bin/bash
Args=("$@")
Name=${Args[0]}
varname=$(ls | grep -m 1 $Name.tex)
nvim $varname
