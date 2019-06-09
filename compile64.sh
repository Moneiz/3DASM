#!/bin/bash

if [ $# -ne 1 ]
then	echo "Usage : $0 code_pour_dessiner.asm"
		exit
fi

nom=`echo $1 | cut -d. -f1`

nasm -felf64 -Fdwarf -g -l $nom.lst $1 -o $nom.o
if [ $? -eq 0 ]
then	echo "Assemblage OK"
		echo "Création de l'exécutable"
		gcc -fPIC $nom.o -o $nom 3DUTILS.o  -fno-pie -no-pie --for-linker /lib64/ld-linux-x86-64.so.2 -lX11
		if [ $? -eq 0 ]
		then	echo "Fichier exécutable '$nom' créé"
		fi
fi
