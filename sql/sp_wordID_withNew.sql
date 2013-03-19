/*
 * wordID_withNew
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 */

DROP FUNCTION IF EXISTS wordID_withNew;
DELIMITER ;;

CREATE FUNCTION `wordID_withNew`(_word VARCHAR(128)) RETURNS INT(10) UNSIGNED
    MODIFIES SQL DATA
    DETERMINISTIC

/*
 * Returns the word_id from the word table for a given input string.  The
 * word should be pre-processed.  If no word_id currently exists and
 * then it is allocated.
 */

BEGIN

DECLARE _word_id INT UNSIGNED DEFAULT 0;
DECLARE _found BOOLEAN DEFAULT TRUE;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET _found = FALSE;

-- Find the word in the index, if it's there
SELECT word_id INTO _word_id FROM word WHERE string = _word;

IF _found THEN
    -- The word was found, so return the ID
    RETURN _word_id;
ELSE
    -- One needs to be allocated, so we need to add it
    INSERT INTO word (string) VALUES (_word);
    RETURN LAST_INSERT_ID();
END IF;


END;;
DELIMITER ;
