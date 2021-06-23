#! /bin/bash

[[ ! $(which scrot) ]] && echo "Necessário instalar o scrot"&& exit

DIRECTORY="$HOME/.config/"
BROWSER_STATUS=1

# INICIO estrutura de diretórios
main() {
    
    DATE=$(date +%D | tr "/" "-")
    mkdir -p $DIRECTORY/mons
    monitora

}
# FIM

# INICIO identifica se o aplicativo gatilho está rodando
sentinela() {

	while [ -e $USER ]
	do
		BROWSER_STATUS=$(pgrep -u $USER firefox; pgrep -u $USER opera)
	done

main
}

# INICIO determina tempo e tira screenshot da tela, salvando em local pré-determinado
printscreen() { 
	sleep 5
	scrot ~/.config/mons/img-$(date +%H-%M-%s).png
}
# FIM

# INICIO inicia o script
monitora() {


	while [ -z $fire ]
	do
		printscreen
	done

	sentinela

}
# FIM

main
