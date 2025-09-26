#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome to My Salon, how can I help you?"
  fi

  #get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$AVAILABLE_SERVICES" | while IFS='|' read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1|2|3|4|5) APPOINTMENT_MENU ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac
}

APPOINTMENT_MENU(){
  #get service name
  SERVICE_ID_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

  #get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  #ask for time appointment
  echo -e "\nWhat time would you like your $SERVICE_ID_NAME, $CUSTOMER_NAME?"

  #verify time format
  while true; do
    read SERVICE_TIME

    if [[ ! $SERVICE_TIME =~ ^([0-1][0-9]|2[0-3]):[0-5][0-9]$ ]]
    then
      echo -e "\nTime not recognized. Please enter a time in HH:MM format."
    else
      #insert new appointment
      
      #show the appointment to user
      echo -e "\nI have put you down for a $SERVICE_ID_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      break
    fi
  done

}

MAIN_MENU