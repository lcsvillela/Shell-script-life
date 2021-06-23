#! /bin/bash

echo -e
"\n======================
||   CONFIGURANDO    ||
||      IPTABLES     ||
=======================\n"


IPT=iptables
CONFIGURACAO=3 # CHAVE - 1 deixa tudo aberto, 2 padroniza tudo como drop e libera as especificadas,
	       # 3 padroniza drop e fecha as de acesso remoto
WIFI=wlp1s0
CABO=enp2s0


declare WEB=(1 23 123 159 147 852 156)
declare REMOTO=(154 147 128 146 123 158)
declare LOG=(1478 125 1456 254 222 111 333 666)
declare -A POLITICA

case $CONFIGURACAO in
	1) POLITICA=( [WEB]=ACCEPT [REMOTO]=ACCEPT [PADRAO]=ACCEPT);;
	2) POLITICA=( [WEB]=ACCEPT [REMOTO]=ACCEPT [PADRAO]=DROP);;
	3) POLITICA=( [WEB]=ACCEPT [REMOTO]=DROP [PADRAO]=DROP);;
	4) POLITICA=( [WEB]=DROP [REMOTO]=DROP [PADRAO]=DROP);;
	*) POLITICA=( [WEB]=ACCEPT [REMOTO]=DROP [PADRAO]=DROP);;
esac


# Ativar modulos
modprobe iptable_nat
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp
modprobe ipt_LOG
modprobe ipt_REJECT
modprobe ipt_MASQUERADE


#limpando configurações
$IPT -X
$IPT -F


#aplicando politica padrao
$IPT -P INPUT ${POLITICA[PADRAO]}
$IPT -P OUTPUT ${POLITICA[PADRAO]}
$IPT -P FORWARD ${POLITICA[PADRAO]}
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT


function main(){
	adm_portas
	restricoes_fluxo
	configuracao_sistema
}


function adm_portas(){

#liberando portas WEB
	for i in $(echo ${WEB[@]})
	do
		$IPT -A INPUT -p tcp --dport $i -j ${POLITICA[WEB]}
		$IPT -A INPUT -p udp --dport $i -j ${POLITICA[WEB]}
		echo "Porta ${WEB[$i]} está ${POLITICA[WEB]} TCP/UDP"
	done


#Liberando portas de acesso remoto
	for i in $( echo ${REMOTO[@]} )
	do
		$IPT -A INPUT -p tcp --dport $i -j ${POLITICA[REMOTO]}
		$IPT -A INPUT -p udp --dport $i -j ${POLITICA[REMOTO]}
		echo "Porta REMOTO[$i está ${POLITICA[REMOTO]} TCP/UDP"
	done

##Registrando portas para registro de Logs
	for i in $( echo ${LOG[@]} )
	do
		$IPT -A INPUT -p tcp --dport $i -j LOG
		$IPT -A INPUT -p udp --dport $i -j LOG
		echo "Porta ${LOG[$i]} será registrada"
	done
}


function restricoes_fluxo (){
#Configurando restrições de envio e recebimento de pacotes
	$IPT -A INPUT -p icmp --icmp-type echo-request -m limit --limit 10/s -j ACCEPT
	$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	$IPT -A INPUT --protocol tcp --tcp-flags ALL SYN,ACK -j DROP
	$IPT -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 10/s -j ACCEPT
	$IPT -A INPUT -p tcp -m limit --limit 10/s -j ACCEPT
	$IPT -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
	$IPT -A OUTPUT -m state --state ESTABLISHED,RELATED,NEW -j ACCEPT
	$IPT -A INPUT -p tcp --dport 443 -m limit --limit 60/s --limit-burst 6 -j ACCEPT
}



function configuracao_sistema(){
#ignorar ping
	echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_all
#protecao contra ip spoof
	echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
#nao responder ao bogus error
	echo "1" > /proc/sys/net/ipv4/icmp_ignore_bogus_error_responses
#ignora o arp
	echo "1" > /proc/sys/net/ipv4/conf/all/arp_ignore
########
	echo "1" > /proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr
###mudando ttl do sistema
	echo "146" > /proc/sys/net/ipv4/ip_default_ttl
#bloqueando syncookies flood
	echo "1" > /proc/sys/net/ipv4/tcp_syncookies
	echo "1" > /proc/sys/net/ipv4/tcp_syn_retries
# ativando ip routing
	echo "0" > /proc/sys/net/ipv4/ip_forward
}


main
