#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t -c"

GAME_PLAY(){
  #Assign names to the argument variables
  USERNAME=$1
  #add one to games played since we have started a new game
  GAMES_PLAYED=$(($2 + 1))
  BEST_GAME=$3

  #Generate a random number and ask the user to guess
  RAND=$((1 + $RANDOM % 1000))
  echo "Guess the secret number between 1 and 1000:"

  #Initial Guess value to start the while loop
  #0 cant be generated so it reads as false
  GUESS=0
  #number of guesses so far
  NUM_GUESS=0

  #while the guess is wrong
  while [[ $GUESS -ne $RAND ]]
  do
    #ask for a guess
    read GUESS
    #number of guess up by one
    NUM_GUESS=$(($NUM_GUESS + 1))
  
    #if guess is not an integer
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    #then we ask for and integer and start the loop again
    then
      echo "That is not an integer, guess again:"

    #otherwise it must be an INT
    else
      #was the guess higher or lower?
      #if lower
      if [[ $GUESS -lt $RAND ]]
      #tell the player RAND was higher
      then
        echo "It's higher than that, guess again:"

      #if higher
      elif [[ $GUESS -gt $RAND ]]
      #tell player RAND was lower
      then
        echo "It's lower than that, guess again:"
      fi
    fi
  done
  #if the player got the guess right, then the loop breaks

  #check for BEST_GAME
  #check to see if this is their first game finished
  if [[ -z $BEST_GAME  ]]
  #if there is no BEST_GAME yet then this is best game
  then
    BEST_GAME=$NUM_GUESS
  
  #else if there is a best game, check if this game was better
  elif [[ $NUM_GUESS < $BEST_GAME ]]
  #if so replace BEST_GAME
  then
    BEST_GAME=$NUM_GUESS
  fi

  #update the database to reflect new number of games played
  #and any update to best_game
  INSERT_RESULT=$($PSQL "UPDATE users 
  SET games_played = $GAMES_PLAYED, 
  best_game = $BEST_GAME 
  WHERE username = '$USERNAME'")

  #congratulate the player
  echo "You guessed it in $NUM_GUESS tries. The secret number was $RAND. Nice job!"

  
}

#Main fucntion
MAIN(){
  #ask the user for their username
  echo "Enter your username:"
  read USERNAME

  #look up their username
  RETURN_RESULT=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
  #gather their info into variables
  read -r USER_ID BAR USER BAR GAMES_PLAYED BAR BEST_GAME <<< $(echo $RETURN_RESULT)

  if [[ -z $RETURN_RESULT ]]
  #if there is no result
  then
    #create a new user
    INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    #welcome them back
    echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  #play the game
  GAME_PLAY $USERNAME $GAMES_PLAYED $BEST_GAME
}

#Call the main fucntion
MAIN