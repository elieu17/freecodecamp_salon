#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Services ~~~~~\n"

# Display service menu
SERVICE_MENU() {
  # Get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
  echo -e "\nHere are the services we provide:"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Ask for which service
  echo -e "\nWhich service would you like?"
  read SERVICE_ID_SELECTED

  # Validate service ID
  SERVICE_EXISTS=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_EXISTS ]]
  then
    echo -e "\nInvalid choice. Please select a valid service."
    SERVICE_MENU
    return
  fi

  # Ask for customer phone
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  # Check if phone exists
  CUSTOMER_PHONE_QUERY=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  # If phone does not exist, insert new customer
  if [[ -z $CUSTOMER_PHONE_QUERY ]]
  then
    # Ask for customer name
    echo -e "\nI see you are a new customer. Please enter your name:"
    read CUSTOMER_NAME
    INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Ask for service time
  echo -e "\nWhat time would you like to come in?"
  read SERVICE_TIME

  # Insert appointment
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES((SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

SERVICE_MENU
