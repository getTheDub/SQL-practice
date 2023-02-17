/* Euro 2020 tournament tracker app: store teams and match-ups, then update scores and who is going on to the next round */

CREATE TABLE teams (
    id INTEGER PRIMARY KEY,
    country_name TEXT,
    group_stage TEXT);

/* Tournament Start */
INSERT INTO teams (group_stage, country_name) VALUES
    ("A", "Cymru"),
    ("A", "Italy"),
    ("A", "Switzerland"),
    ("A", "Turkey"),
    ("B", "Belgium"),
    ("B", "Denmark"),
    ("B", "Finland"),
    ("B", "Russia"),
    ("C", "Nederlands"),
    ("C", "Austria"),
    ("C", "Ukraine"),
    ("C", "N Macedonia"),
    ("D", "Czechia"),
    ("D", "Engerland"),
    ("D", "Croatia"),
    ("D", "Scotland"),
    ("E", "Sweden"),
    ("E", "Slovakia"),
    ("E", "Spain"),
    ("E", "Polska"),
    ("F", "France"),
    ("F", "Germany"),
    ("F", "Portugal"),
    ("F", "Hungary");


/* Matchday 1 */
ALTER TABLE teams ADD points INTEGER default 0;
SELECT group_stage AS Gr, country_name FROM teams;


UPDATE teams SET points = points + 3 WHERE
    country_name IN ("Italy", "Finland", "Belgium", "Austria", "Nederlands", "Engerland", "Czechia", "Slovakia", "Portugal", "France");

UPDATE teams SET points = points + 1 WHERE
    country_name IN ("Cymru", "Switzerland", "Spain", "Sweden");



/* Matchday 2 */
UPDATE teams SET points = points + 3 WHERE
    country_name IN ("Cymru", "Italy", "Russia", "Belgium", "Ukraine", "Nederlands", "Sweden", "Germany");

UPDATE teams SET points = points + 1 WHERE
    country_name IN ("Croatia", "Czechia", "Engerland", "Scotland", "Spain", "Polska", "Hungary", "France");



/* Matchday 3 */
UPDATE teams SET points = points + 3 WHERE
    country_name IN ("Belgium", "Denmark", "Austria", "Nederlands", "Italy", "Switzerland", "Engerland", "Croatia");


SELECT group_stage, country_name, points FROM teams
    ORDER BY group_stage, points DESC, country_name;


/* Preparing for DELETE */
ALTER TABLE teams ADD eliminated INTEGER default 0;

UPDATE teams SET eliminated = 1 WHERE country_name IN ("Turkey", "Russia", "N Macedonia", "Finland", "Scotland", "Polska", "Slovakia", "Hungary");

SELECT id, country_name AS through_to_knockouts, group_stage
    FROM teams
    WHERE eliminated = 0
    ORDER BY group_stage, points DESC, country_name;


DELETE FROM teams WHERE eliminated = 1;





/***** Round of 16 *****/

/* Create a new pairings table then use self JOIN to show matchups for each round */
CREATE TABLE matchups16 (
    id INTEGER PRIMARY KEY,
    home_id INTEGER,
    h_score INTEGER default 0,
    a_score INTEGER default 0,
    away_id INTEGER,
    loser_id INTEGER default NULL);

INSERT INTO matchups16 (home_id, away_id) VALUES
    (5, 23),
    (2, 10),
    (21, 3),
    (15, 19),
    (17, 11),
    (14, 22),
    (9, 13),
    (1, 6);




UPDATE matchups16 SET h_score = abs(random() % 10), a_score = abs(random() % 11);


SELECT matchups16.id, teams.country_name AS home, matchups16.h_score, matchups16.a_score, opponents.country_name AS away FROM teams
    JOIN matchups16
    ON matchups16.home_id = teams.id
    LEFT OUTER JOIN teams opponents
    ON matchups16.away_id = opponents.id;

SELECT matchups16.id, CASE
    WHEN matchups16.h_score > matchups16.a_score
        THEN teams.country_name
    WHEN matchups16.h_score < matchups16.a_score
        THEN opponents.country_name
    ELSE "Tie"
    END "Winner"
    FROM matchups16
    JOIN teams
        ON matchups16.home_id = teams.id
    JOIN teams opponents
        ON matchups16.away_id = opponents.id;


UPDATE matchups16 SET loser_id = home_id WHERE h_score < a_score;
UPDATE matchups16 SET loser_id = away_id WHERE h_score > a_score;

SELECT matchups16.loser_id, teams.country_name AS loser FROM matchups16
    JOIN teams
    ON teams.id = matchups16.loser_id;


UPDATE teams SET eliminated = (SELECT CASE
    WHEN matchups16.loser_id = teams.id
        THEN 1
        ELSE 0
        END
        FROM matchups16);

SELECT id, country_name, eliminated FROM teams;


/*
CASE
    WHEN matchups16.h_score > matchups16.a_score
        THEN "home"
    WHEN matchups16.h_score < matchups16.a_score
        THEN "away"
        END

UPDATE teams
    SET eliminated (CASE WHEN matchups16.h_score > matchups16.a_score THEN teams.country_name END),
    (CASE WHEN matchups16.h_score < matchups16.a_score THEN opponents.country_name END)
    FROM matchups16
    JOIN teams
        ON matchups16.home_id = teams.id
    JOIN teams opponents
        ON matchups16.away_id = opponents.id;*/

        /* not quite but try this syntax: https://stackoverflow.com/questions/19270259/update-with-join-in-sqlite */

/* Wrote all of the original Round of 16 code in comments in one go, without seeing if each piece worked first, then un-commented and the only thing I had to change was addding LEFT OUTER, which was only needed bc I was filling this out while the games were still being decided. Pretty proud of myself for that. */



/* Quarter Finals */
/* Can I automate this next bit? UPDATE teams SET eleminated = 1 WHERE score is less than the other score? I'm guessing it's a CASE WHEN situation.

CASE WHEN matchups16.a_score < matchups16.h_score
    UPDATE teams SET eliminated = 1...

But this seems like I would need to JOIN the tables in an UPDATE function. Is that possible? Looks like it is!
    https://www.sqlite.org/lang_update.html
    https://www.sqlite.org/lang_createtrigger.html
    https://www.w3resource.com/sql/update-statement/update-using-subqueries.php

You'll need to use UPDATE...FROM (SELECT...) or possibly CREATE TRIGGER.

UPDATE teams SET teams.eliminated = 1
    FROM (SELECT matchups16.home_id
        FROM matchups16
        WHERE matchups16.h_score < matchups16.a_score)

I could use the CASE WHEN (and a new losers column) to make matchups16 name a loser and then UPDATE FROM to change eliminated based on the losers, but that seems redundant. Is there a way to do it in one stroke?
*/

/*
CREATE TABLE matchups_quarters (
    id INTEGER PRIMARY KEY,
    home_id INTEGER,
    h_score INTEGER default 0,
    a_score INTEGER default 0,
    away_id INTEGER);

INSERT INTO matchups_quarters (home_id, away_id) VALUES
    (NULL, NULL),
    (NULL, NULL),
    (NULL, NULL),
    (NULL, NULL);
*/


/* Semi Finals */
/*
CREATE TABLE matchups_semis (
    id INTEGER PRIMARY KEY,
    home_id INTEGER,
    h_score INTEGER default 0,
    a_score INTEGER default 0,
    away_id INTEGER);

INSERT INTO matchups_semis (home_id, away_id) VALUES
    (NULL, NULL),
    (NULL, NULL);
*/



/* Final!!!! */
/*
CREATE TABLE matchups_final (
    id INTEGER PRIMARY KEY,
    home_id INTEGER,
    h_score INTEGER default 0,
    a_score INTEGER default 0,
    away_id INTEGER);

INSERT INTO matchups_final (home_id, away_id) VALUES
    (NULL, NULL);
*/
