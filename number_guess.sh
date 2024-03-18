#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


MAIN() {
  echo "Enter your username:"
  read ENTERED_USERNAME

  # Get data (username, games_played, best_game) from database
  USERNAME=$($PSQL "SELECT username FROM users_information WHERE username='$ENTERED_USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users_information WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users_information WHERE username='$USERNAME'")
  if [[ -z $USERNAME ]]
  # If username is not in database, insert it
  then
    INSERT_USERNAME=$($PSQL "INSERT INTO users_information(username) VALUES('$ENTERED_USERNAME')")
    echo "Welcome, $ENTERED_USERNAME! It looks like this is your first time here."
  # If username exists print out appropriate dialogue and increment games played
  else
    echo "Welcome back, $ENTERED_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    ((GAMES_PLAYED++))
    INSERT_GAMES_PLAYED=$($PSQL "UPDATE users_information SET games_played = $GAMES_PLAYED WHERE username='$ENTERED_USERNAME'")

  fi


  # Start playing game
  SECRET_NUMBER=$((1 + $RANDOM % 1000))
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  N_GUESS=1
  until [[ $GUESS == $SECRET_NUMBER ]]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then 
      echo "That is not an integer, guess again:"
      read GUESS
    else
      if [[ $GUESS < $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
        read GUESS
      else
        echo "It's lower than that, guess again:"
        read GUESS
      fi
      ((N_GUESS++))
    fi

  done
  echo "You guessed it in $N_GUESS tries. The secret number was $SECRET_NUMBER. Nice job!"

  # Update best game
  if [[ -z $USERNAME ]]
  # If this is first game, then insert N_GUESS directly
  then
    UPDATE_BEST_GAME=$($PSQL "UPDATE users_information SET best_game = $N_GUESS WHERE username='$ENTERED_USERNAME'")
  else
    if [[ $N_GUESS < $BEST_GAME ]]
    then
      UPDATE_BEST_GAME=$($PSQL "UPDATE users_information SET best_game = $N_GUESS WHERE username='$ENTERED_USERNAME'")
    fi
  fi
}

MAIN