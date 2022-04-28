-- SELECT QUERIES
SELECT genreName AS genre FROM genres;

SELECT singerName AS name, homeCity AS city, homeState AS state FROM singers;

SELECT albumName as name, singerName as singer, albumReleaseDate AS releaseDate
FROM albums
INNER JOIN singers_albums ON albums.albumID = singers_albums.albumID
INNER JOIN singers ON singers_albums.singerID = singers.singerID;

SELECT songName, singerName, albumName, genreName
FROM songs
INNER JOIN songs_singers ON songs.songID = songs_singers.songID
INNER JOIN singers ON songs_singers.singerID = singers.singerID
INNER JOIN albums ON songs.album = albums.albumID
INNER JOIN genres ON songs.genre = genres.genreID;


-- UPDATE QUERIES
UPDATE genres
SET genreName = "Pop"
WHERE genreID = "3";

UPDATE albums
SET albumName = "My Beautiful Dark Twisted Fantasy", albumReleaseDate = 2010-11-22
WHERE albumID = "1";

UPDATE singers
SET singerName = "Kanye West", homeCity = "Atlanta", homeState = "CA"
WHERE singerID = "1";

UPDATE songs
SET album=(SELECT albumID FROM albums WHERE albumName="My Beautiful Dark Twisted Fantasy"), genre=(SELECT genreID from genres WHERE genreName="Rap"), songName="Gorgeous"
WHERE songID = "1";


-- DELETE QUERIES
-- Delete from genres
UPDATE songs
SET genre = NULL
WHERE genre = "1";

DELETE FROM genres
where genreID = "1";

-- Delete from albums
DELETE FROM singers_albums
WHERE albumID = "1";

UPDATE songs
SET album = NULL
WHERE album = "1";

DELETE FROM albums
WHERE albumID = "1";

-- Delete from singers
DELETE from singers_albums
WHERE singerID = "1";

DELETE FROM songs_singers
WHERE singerID = "1";

DELETE FROM singers
WHERE singerID = "1";

-- Delete from songs
DELETE FROM songs
WHERE songID = "1";

-- Delete songs_singers relationships (Note there are two separate queries here)
DELETE FROM songs_singers
WHERE singerID = "1";

DELETE FROM songs_singers
WHERE songID = "1";

-- Delete singer_albums relationship (Note there are two separate queries here)
DELETE FROM singers_albums
WHERE singerID = "1";

DELETE FROM singers_albums
WHERE albumID = "1";


-- SEARCH QUERIES
SELECT songName, singerName, albumName, genreName
FROM songs
INNER JOIN songs_singers ON songs.songID = songs_singers.songID
INNER JOIN singers ON songs_singers.singerID = singers.singerID
INNER JOIN albums ON songs.album = albums.albumID
INNER JOIN genres ON songs.genre = genres.genreID
WHERE songName = "Toxic";

SELECT genreName
FROM genres
WHERE genreName = "Pop";


-- INSERT QUERIES
INSERT INTO albums(albumName, albumReleaseDate)
VALUES ("How Do You Feel Now?", "4-21-2015");
       
INSERT INTO genres(genreName)
VALUES ("Indie Rock");
       
INSERT INTO songs(songName, album, genre)
VALUES ("Destruction", (SELECT albumID from albums where albumName = "How Do You Feel Now?"), (SELECT genreID FROM genres WHERE genreName = "Indie Rock"));
      
INSERT INTO singers(singerName, homeCity, homeState)
VALUES ("Joywave", "Rochester", "NY");

INSERT INTO singers_albums(singerID, albumID)
VALUES ((SELECT singerID FROM singers WHERE singerName = "Joywave"), (SELECT albumID FROM albums WHERE albumName = "How Do You Feel Now?"));

INSERT INTO songs_singers(songID, singerID)
VALUES ((SELECT songID FROM songs WHERE songName = "Destruction"), (SELECT singerID FROM singers WHERE singerName = "Joywave"));
