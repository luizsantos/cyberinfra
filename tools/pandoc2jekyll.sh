#!/bin/bash

dir="/mnt/deposito/cyberinfra/tools/"

if [ -z "$1" ]; then
    echo -e " Digite o comando e o nome do arquivo em MarkDown, tal como:\n\t$0 arquivo.md"
    exit 1
else
    if [ -e $1 ]; then
        fName="$(basename "$1" .md)"
        fNameOut="${fName}J.md"
        pandoc $fName.md -o $fName-tmp.md --lua-filter=$dir/troca_note.lua --filter pandoc-crossref --metadata layout=post --standalone --template=$dir/minimal.yaml

        sed 's/{#[^}]*}//g' $fName-tmp.md > $fNameOut

        rm $fName-tmp.md

        echo "Arquivo $fNameOut gerado..."
    else
        echo "$1 - arquivo não encontrado"
        exit 1
    fi
fi
exit 0
