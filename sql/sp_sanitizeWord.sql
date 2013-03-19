/*
 * sanitizeWord
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 */

DROP FUNCTION IF EXISTS sanitizeWord;
DELIMITER ;;

CREATE FUNCTION `sanitizeWord`(_word VARCHAR(128)) RETURNS VARCHAR(128)
    NO SQL
    DETERMINISTIC

/*
 * Returns a tidied-up word, ready for insertion (or comparison) with the word table.
 */

BEGIN

RETURN LOWER(TRIM(_word));

END;;
DELIMITER ;
