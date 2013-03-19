/*
 * wordID
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 */

DROP FUNCTION IF EXISTS wordID;
DELIMITER ;;

CREATE FUNCTION `wordID`(_word VARCHAR(128)) RETURNS INT(10) UNSIGNED
    READS SQL DATA
    DETERMINISTIC

/*
 * Returns the word_id from the word table for a given input string.  The
 * word should be pre-processed.  If no word_id currently exists then it
 * is NOT allocated: use wordID_withNew for that.
 */

BEGIN

DECLARE _word_id INT UNSIGNED;

-- Find the word in the index, if it's there
SELECT word_id INTO _word_id FROM word WHERE string = _word;

RETURN _word_id;

END;;
DELIMITER ;
