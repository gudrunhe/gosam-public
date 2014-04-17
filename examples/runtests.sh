#!/bin/bash

echo ------------------------------------------------------------
echo "$ uname -a"
uname -a
echo ------------------------------------------------------------
echo "$ cat /proc/cpuinfo | grep 'model name'"
cat /proc/cpuinfo | grep 'model name'
echo ------------------------------------------------------------
echo "START `date +'%s'`"
echo ------------------------------------------------------------
echo "DIR $*"
echo ------------------------------------------------------------

if [ ! -f "setup.in" ]
then
	gosam-config.py setup.in
fi

if [ "$#" == "0" ]; then

for f in *
do
	if test -d "$f" -a -f "$f/Makefile"
	then
		rm -f "$f/test/test.log"
	fi
done
for f in *
do
	if test -d "$f" -a -f "$f/Makefile"
	then
		printf "Running 'make very-clean' in $f ...\n"
		make -C "$f" very-clean \
		|| printf "make very-clean failed\n@@@ FAILURE @@@\n" \
			> "$f/test/test.log"

		printf "Running 'make test' in $f...\n"
		make -C "$f" test \
		|| printf "make test failed\n@@@ FAILURE @@@\n" \
			> "$f/test/test.log"
	fi
done

else

while (( "$#" )); do
	if test -d "$1" -a -f "$1/Makefile"
	then
		printf "Running 'make very-clean' in $1 ...\n"
		make -C "$1" very-clean \
		|| printf "make very-clean failed\n@@@ FAILURE@@@\n" \
			> "$1/test/test.log"

		printf "Running 'make test' in $1...\n"
		make -C "$1" test \
		|| printf "make test failed\n@@@ FAILURE@@@\n" \
			> "$1/test/test.log"
	fi

	shift
done
fi
		
echo ------------------------------------------------------------
echo "DONE `date +'%s'`"
echo ------------------------------------------------------------
