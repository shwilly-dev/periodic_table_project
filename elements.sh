#!/bin/bash

PSQL="psql -U freecodecamp --dbname=periodic_table -A -t -c"
OIFS=$IFS

SHOW_RESULT() {
  if [[ ! $ELEMENT_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    IFS="|"
    read ATOMIC_NUMBER SYMBOL NAME MASS MELTING_POINT BOILING_POINT TYPE_ID <<< "$ELEMENT_RESULT"
    IFS=$OIFS

    TYPE=$($PSQL "SELECT type FROM types WHERE type_id = '$TYPE_ID'")

    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
}

if [[ ! $1 ]]
then
  echo "Please provide an element as an argument."
elif [[ $1 =~ ^[0-9]+$ ]]
then
  #query db with atomic number
  ELEMENT_RESULT=$($PSQL "SELECT elements.atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM elements FULL JOIN properties ON elements.atomic_number = properties.atomic_number WHERE elements.atomic_number = '$1'")

  SHOW_RESULT

elif [[ $1 =~ ^[A-Z]([a-z])?$ ]]
then
  #query db with symbol
  ELEMENT_RESULT=$($PSQL "SELECT elements.atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM elements FULL JOIN properties ON elements.atomic_number = properties.atomic_number WHERE symbol = '$1'")

  SHOW_RESULT

elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
then
  #query db with name
  ELEMENT_RESULT=$($PSQL "SELECT elements.atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM elements FULL JOIN properties ON elements.atomic_number = properties.atomic_number WHERE name = '$1'")

  SHOW_RESULT

else
  echo "I could not find that element in the database."
fi
