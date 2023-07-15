#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

IDENTIFICADOR=$1
MAIN(){
	if [[ $IDENTIFICADOR ]]
	then
		ENCONTRAR_ATOMIC_NUMBER
		MOSTRAR_ELEMENTO
	else
		echo -e "Please provide an element as an argument."
	fi
}

ENCONTRAR_ATOMIC_NUMBER(){
	if [[ $IDENTIFICADOR =~ ^[0-9]+$ ]]
	then
		ENCONTRAR_POR_NUMERO
	else
		if [[ ${#IDENTIFICADOR}<3 ]]
		then
			ENCONTRAR_POR_SIMBOLO
		else
			ENCONTRAR_POR_NOMBRE
		fi
	fi
}

ENCONTRAR_POR_NUMERO(){
	ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE $IDENTIFICADOR=atomic_number")
}

ENCONTRAR_POR_SIMBOLO(){
	ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE '$IDENTIFICADOR'=symbol")
}

ENCONTRAR_POR_NOMBRE(){
	ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE '$IDENTIFICADOR'=name")
}

NO_EXISTE(){
	echo "I could not find that element in the database."
	exit
}

MOSTRAR_ELEMENTO(){
	if [[ $ATOMIC_NUMBER ]]
	then
		DATOS=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE $ATOMIC_NUMBER=atomic_number")

		echo "$DATOS" | while IFS="|" read TIPOID NUMEROATOMICO SIMBOLO NOMBRE MASAATOMICA PUNTOFUSION PUNTOEBULLICION TIPO
		do
			echo "The element with atomic number $NUMEROATOMICO is $NOMBRE ($SIMBOLO). It's a $TIPO, with a mass of $MASAATOMICA amu. $NOMBRE has a melting point of $PUNTOFUSION celsius and a boiling point of $PUNTOEBULLICION celsius."
		done
	else
		NO_EXISTE
	fi
	
}

MAIN
