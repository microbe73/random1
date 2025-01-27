#!/bin/bash
Args=("$@")
Name=${Args[0]}
Search=${Args[1]}
echo s\" $Name\" init s\" $Search\" gl scmul bye | gforth ed.fs
