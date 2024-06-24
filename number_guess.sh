#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t -c"

#RAND=$((1 + $RANDOM % 1000))
#echo $RAND

#Main fucntion
MAIN(){
  #ask the user for their username
  echo "Enter your username:"
  read USERNAME

  #look up their username
  RETURN_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
  
  if [[ -z $RETURN_RESULT ]]
  #if there is no username
  then
    #create a new user
    INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    #gather their info into variables
    read -r USER_ID BAR USERNAME BAR GAMES_PLAYED BAR BEST_GAME <<< $(echo $RETURN_RESULT)
    #and welcome them back
    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

#Call the main fucntion
MAIN