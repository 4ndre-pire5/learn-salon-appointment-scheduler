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
    AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

    echo "$AVAILABLE_SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done

    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED ")
    SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//')

    if [[ -z $SERVICE_NAME ]]
    then
        MAIN_MENU "I could not find that service. What would you like today?"
    else
        APPOINTMENT_MENU
    fi
}

APPOINTMENT_MENU(){
 
    #get customer phone
    echo -e "\nWhat's your phone number?"

    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *//;s/ *$//')

    #if customer name doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
        #get new customer name
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME

        #insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    #get service name
    SERVICE_NAME_FINAL=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

    #ask for time appointment
    echo -e "\nWhat time would you like your $SERVICE_NAME_FINAL, $CUSTOMER_NAME?"
    read SERVICE_TIME

    #get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    #insert new appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (time, customer_id, service_id) VALUES('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED')")

    #show the appointment to user
    echo -e "\nI have put you down for a $SERVICE_NAME_FINAL at $SERVICE_TIME, $CUSTOMER_NAME."

    exit 0
  
}

MAIN_MENU