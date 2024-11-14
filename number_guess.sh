#!/bin/bash

# Connection to the database
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Starts the game
START() {
  echo -e "\n~~~~~ Number Guessing Game ~~~~~\n" 

  #get username
  echo "Enter your username:"
  read USERNAME

  #get username from db
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

  #if user present
  if [[ $USER_ID ]] 
  then
    #get games played
    GAMES_PLAYED=$($PSQL "SELECT count(user_id) FROM games WHERE user_id = '$USER_ID'")

    #get best game (guess)
    BEST_GUESS=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = '$USER_ID'")

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  else
    #if u_name not present in db
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

    #insert to users table
    INSERTED_TO_USERS=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")

    #get user_id
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  fi

  # Starts guessing
  GUESS
}

# Gameplay happens here
GUESS() {
  # Generates random number
  RANDOM_NUMBER=$((1 + $RANDOM % 1000))

  # count guesses
  GUESS_COUNT=0

  #guess number
  GUESSED=0
  echo -e "\nGuess the secret number between 1 and 1000:"

  while [[ $GUESSED = 0 ]]
  do
    read GUESS

    #if not a number
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:" 
    #if correct guess
    elif [[ $RANDOM_NUMBER = $GUESS ]]
    then
      GUESS_COUNT=$(($GUESS_COUNT + 1))
      echo -e "\nYou guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"

      # Insert it into DB
      INSERTED_TO_GAMES=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $GUESS_COUNT)")
      GUESSED=1
    #if greater
    elif [[ $RANDOM_NUMBER -gt $GUESS ]]; then
      GUESS_COUNT=$(($GUESS_COUNT + 1))
      echo -e "\nIt's higher than that, guess again:"
    #if smaller
    else
      GUESS_COUNT=$(($GUESS_COUNT + 1))
      echo -e "\nIt's lower than that, guess again:"
    fi
  done

  echo -e "\nThanks for playing :)\n"
}

START
