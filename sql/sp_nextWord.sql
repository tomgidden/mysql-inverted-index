/*
 * nextWord
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 */

DROP PROCEDURE IF EXISTS nextWord;
DELIMITER ;;

CREATE PROCEDURE `nextWord`(INOUT _sentence TEXT, OUT _word TEXT)
    NO SQL
    DETERMINISTIC

/*
 * This routine takes a string ("_sentence") and returns the first word *
 * found.  It also modifies the sentence parameter, trimming off the found
 * word.
 *
 * As triggers can't (apparently) create temporary tables, the
 * "parseWords" method of splitting the words into a temporary table in
 * one go and using a cursor to iterate through them cannot be used in the
 * indexing task.  So instead, this self-contained function can be used
 * in this specific case.
 */

thisproc:BEGIN

-- Character-counting gubbins.
DECLARE _nextChar CHAR(1);
DECLARE _len INT DEFAULT 0;		-- Length of sentence
DECLARE _base INT DEFAULT 0;	-- Start of word
DECLARE _incr INT DEFAULT 0;	-- End of word (absolute position)

-- If the sentence is null or blank, then skip.
IF (_sentence IS NULL OR _sentence = '') THEN
    SET _word = NULL;
    SET _sentence = NULL;
    LEAVE thisproc;
END IF;

-- Get length of sentence
SET _len = LENGTH(_sentence);

-- Slew through leading non-word chars
REPEAT
    SET _base = _base + 1;
    SET _nextChar = SUBSTRING(_sentence, _base, 1);
UNTIL (_nextChar REGEXP '[[:alnum:]]' OR _base > _len) END REPEAT;

-- If no char was found then this string doesn't contain any word chars.
IF (_base > _len) THEN
    SET _word = NULL;
    SET _sentence = NULL;
    LEAVE thisproc;
END IF;

-- Start letter counting from the base position.
SET _incr = _base;

-- Clear word.
SET _word = '';

-- Slew through word looking for first non-word character, building the
-- result word as we go.
WHILE (_nextChar REGEXP '[[:alnum:]]' AND _incr <= _len) DO
    SET _word = CONCAT(_word, _nextChar);
    SET _incr = _incr + 1;
    SET _nextChar = SUBSTRING(_sentence, _incr, 1);
END WHILE;

-- If we found the end of the string, then force _sentence to NULL.  Else,
-- chop off the found word from the sentence for next time.
IF (_incr > _len) THEN
    SET _sentence = NULL;
ELSE
    SET _sentence = SUBSTRING(_sentence, _incr);
END IF;

END;;
DELIMITER ;
