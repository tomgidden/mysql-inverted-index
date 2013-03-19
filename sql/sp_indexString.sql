/*
 * indexString
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 */

DROP PROCEDURE IF EXISTS indexString;
DELIMITER ;;

CREATE PROCEDURE `indexString`(_id INT UNSIGNED, _sentence TEXT, _classId INT UNSIGNED)

/*
 * This routine takes a string ("_sentence") and indexes it by word into
 * the search_index table.
 *
 * _id is the primary key of the base table to associate this index with.
 *
 * _classId is the search_class_id that the sentence is to be indexed to.
 */

BEGIN

-- Iterator counter for word loop
DECLARE _i INT UNSIGNED DEFAULT '0';

-- Found word
DECLARE _word VARCHAR(128);

-- ID for found word
DECLARE _wordId INT UNSIGNED;

-- First, start off with a clean slate for this article.  Far easier
-- than trying to update the index for a changed row
DELETE FROM search_index WHERE id = _id AND search_class_id = _classId;

-- Find the first word in the sentence
CALL nextWord(_sentence, _word);

-- Okay.  For each word...
WHILE (_word IS NOT NULL) DO

    -- Get word ID for this word, allocating a new one if necessary
    SET _wordId = wordID_withNew(sanitizeWord(_word));

    -- Insert index row for this word.
    INSERT INTO search_index (id, search_class_id, word_id, position)
                        VALUES (_id, _classId, _wordId, _i);

    -- Update word count
    SET _i = _i + 1;

    -- Get the next word
    CALL nextWord(_sentence, _word);

END WHILE;

END;;
DELIMITER ;
