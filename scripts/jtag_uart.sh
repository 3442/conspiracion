#!/bin/sh

exec $(tail -1 $(which quartus) | cut -d' ' -f1-2 | sed 's@quartus/bin/quartus@quartus/bin/nios2-terminal@')
