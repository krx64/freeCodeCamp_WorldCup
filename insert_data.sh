#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# psql --username=freecodecamp --dbname=postgres
# CREATE DATABASE worldcup;
# \c worldcup
# CREATE TABLE teams(team_id SERIAL PRIMARY KEY, name VARCHAR(30) UNIQUE NOT NULL);
# CREATE TABLE games(game_id SERIAL PRIMARY KEY, year INT NOT NULL, round VARCHAR(30) NOT NULL, winner_id INT REFERENCES teams(team_id) NOT NULL, opponent_id INT REFERENCES teams(team_id) NOT NULL, winner_goals INT NOT NULL, opponent_goals INT NOT NULL);

echo "$($PSQL "TRUNCATE TABLE games, teams")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    TEAM=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
    if [[ -z $TEAM ]]  # if WINNER variable is empty / team is not found (not yet in Teams table)
    then
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "-> Added to database - Team: $WINNER"
      fi
    fi
    TEAM=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
    if [[ -z $TEAM ]]  # if OPPONENT variable is empty / team is not found (not yet in Teams table)
    then
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM == "INSERT 0 1" ]]
      then
        echo "-> Added to database - Team: $OPPONENT"
      fi
    fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo "-> Added to database - Game: $YEAR - $WINNER vs. $OPPONENT - $WINNER_GOALS:$OPPONENT_GOALS"
    fi
  fi
done

