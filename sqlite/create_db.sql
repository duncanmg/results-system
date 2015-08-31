CREATE TABLE match ( id INT,
date STRING,
 division_id INT,
 played_yn STRING);

CREATE TABLE match_details (
id   INT,
match_id INT,home_away STRING,
team_id   INT,
result    STRING,
runs_scored INT,
wickets_lost INT,
runs_conceded INT,
wickets_taken INT,
batting_points INT,
bowling_points INT,
 result_points  INT,
penalty_points INT,
 total_points   INT);

CREATE TABLE division ( id INT, name STRING );

CREATE TABLE team ( id INT, name STRING );

