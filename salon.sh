#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Nano's Salon ~~\n"

GET_SERVICES() {
  # If there's an argument
  if [[ -z $1 ]]
  then
    # Standard greeting
    echo -e "Select a service:"

  else
    # Replace gretting with arg
    echo -e "\n$1"
  fi

  # list all available services
  echo -e "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID SERVICE_NAME;
  do
    # ignore non-numbers
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]

    then
      #list services
      echo "$SERVICE_ID) $SERVICE_NAME" | sed 's/ |//g'

    fi

  done
}

BOOK_SERVICE() {
  # get service id from client
  read SERVICE_ID_SELECTED

  # if not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    GET_SERVICES "Enter a valid service number:"

  else
    # Check if service exists
    BOOKING=$($PSQL "
      SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED
    ")

    # if booking is empty
    if [[ -z $BOOKING ]]
    then
      GET_SERVICES "Invalid. Pick one number below:"

    else
      # get phone number
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if phone not in db
      if [[ -z $CUSTOMER_NAME ]] #[[ -z $($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'") ]]
      then
        # get customer name
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME

        echo "Hello $CUSTOMER_NAME, we're adding you to our database"

        # add customer to db
        echo -e "$($PSQL "
          INSERT INTO customers(phone, name)
          VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')
        ")"

      fi
      
      # select a time
      echo -e "\nWhat time would you like to schedule your appointment?"
      read SERVICE_TIME

      # get customer id
      CUSTOMER_ID=$($PSQL "
        SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'
      ")
        
      # book appointment
      echo -e "$($PSQL "
        INSERT INTO appointments(customer_id, service_id, time)
        VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')
      ")"

      # get service name
      SERVICE_NAME=$($PSQL "
        SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED
      ")

      # format customer name
      CUSTOMER_NAME_FORMATTED=$(echo "$CUSTOMER_NAME" | sed -E 's/^ *//g')
      SERVICE_NAME_FORMATTED=$(echo "$SERVICE_NAME" | sed -E 's/^ *//g')

      # confirmation message
      echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."

    fi
  fi
}

GET_SERVICES
BOOK_SERVICE




