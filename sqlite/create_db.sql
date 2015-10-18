CREATE TABLE 
match ( id INT,
date STRING,
division_id INT,
played_yn STRING,
PRIMARY KEY(id));

CREATE TABLE match_details (
id             INT,
match_id       INT NOT NULL,
home_away      STRING,
team_id        INT NOT NULL,
result         STRING,
runs_scored    INT,
wickets_lost   INT,
runs_conceded  INT,
wickets_taken  INT,
batting_points INT,
bowling_points INT,
result_points  INT,
penalty_points INT,
total_points   INT,
PRIMARY KEY(id));

CREATE TABLE division ( id INT, name STRING );

CREATE TABLE team ( id INT, name STRING );

