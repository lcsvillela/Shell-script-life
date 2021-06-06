#! /bin/bash

if [ $(test $(which scrot); echo $?) == 1 ]
then
	echo "Necessário instalar o scrot"
	exit
fi

DIRECTORY="$HOME/.config/"
BROWSER_STATUS=1

# INICIO estrutura de diretórios
starta() {
    
    DATE=$(date +%D | tr "/" "-")
	mkdir -p $DIRECTORY/mons
	dird=$(ls $DIRECTORY/mons/ | grep $DATE)
    monitoring

}
# FIM

# INICIO identifica se o aplicativo gatilho está rodando
waiting() {

while [ -e $USER ]
do
	BROWSER_STATUS=`pgrep -u $USER firefox; pgrep -u $USER opera`
done

starta
}

# INICIO determina tempo e tira screenshot da tela, salvando em local pré-determinado
screenT() { 
	sleep 5
	scrot ~/.config/mons/img-`date +%H-%M | tr "/" "-"`-$RANDOM.png
}
# FIM

# INICIO inicia o script
monitoring() {


while [ -z $fire ]
do
	screenT
done

waiting

}
# FIM

starta
