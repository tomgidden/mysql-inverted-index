/*
 * buildSearchParts_parseWords
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This version of "buildSearchParts" uses "parseWords" and a cursor to
 * separate words.  This may be more efficient and more flexible.
 * However, it requires the procedure to use "MODIFIES SQL DATA".  I have
 * a feeling this may affect caching and concurrency.  The other approach
 * is to use "nextWord" which does not affect the database.
 *
 */

DROP PROCEDURE IF EXISTS buildSearchParts_parseWords;
DELIMITER ;;

CREATE PROCEDURE `buildSearchParts_parseWords`(_classId INT UNSIGNED,
                                              _sentence TEXT,
                                              _type ENUM('and', 'ordered', 'phrase'),
                                              INOUT _froms TEXT,
                                              INOUT _wheres TEXT)
    DETERMINISTIC -- is this true?  Hrmm...
    MODIFIES SQL DATA -- as parseWords_result is used.
thisproc:BEGIN

--
-- Internal Variables
--
DECLARE _word VARCHAR(128) DEFAULT NULL;
DECLARE _wordCount INT UNSIGNED DEFAULT '0';
DECLARE _wordId INT UNSIGNED;

-- Iterator counter for word loop
DECLARE _i INT DEFAULT 0;

-- Defining cursor for iterating over parsed input words
DECLARE _continue_loop_words INT DEFAULT 1;
DECLARE cursor_words CURSOR FOR SELECT word FROM parseWords_result;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET _continue_loop_words = NULL;

-- Call proc to parse input words into temp table.
CALL parseWords(_sentence);
SELECT count(*) FROM parseWords_result INTO _wordCount;

-- Leave procedure if there are no parsed results.
IF !(_wordCount > 0) THEN
   LEAVE thisproc;
END IF;

-- Start adding words
OPEN cursor_words;
loop_words: LOOP
    -- Cursor control (the table contains word positions, but its
    -- not fetched)
    FETCH cursor_words INTO _word;
    IF (_continue_loop_words is NULL) THEN
       LEAVE loop_words;
    END IF;

    -- Get the ID for this word
    SET _wordId = wordID(_word);

    -- If no word was found, this whole thing's a waste of time
    -- anyway, as no rows will be returned.
    IF (_wordId IS NULL) THEN
        SET _froms = NULL;
        SET _wheres = _word;
        LEAVE thisproc;
    END IF;

    -- Assemble an inner join from one copy of the index table to the
    -- previous one.
    IF (_i=0) THEN
        -- This is the first word, so we just establish the conditions for
        -- i0.  i0 has already nbeen specified in the original query
        -- string initialisation.
        SET _wheres = CONCAT(_wheres,
                             'i0.search_class_id=',_classId,
                             ' AND i0.word_id=',_wordId);
    ELSE
        -- This is a subsequent word, so we join against i0.
        SET _froms = CONCAT(_froms,
                            ' INNER JOIN search_index AS i',_i,
                            ' ON i0.id=i',_i,'.id');
        SET _wheres = CONCAT(_wheres,
                             ' AND i',_i,'.search_class_id=',_classId,
                             ' AND i',_i,'.word_id=',_wordId);

        IF (_type = 'phrase') THEN
            -- This is a phrase search, so we need to specify word position.
            SET _wheres = CONCAT(_wheres,
                                 ' AND i',_i,'.position=',
                                 'i0.position+',_i);
        ELSEIF (_type = 'ordered') THEN
            -- This is an ordered search, so we need to specify word position.
            SET _wheres = CONCAT(_wheres,
                                 ' AND i',_i,'.position>i',(_i-1),'.position');
        END IF;
    END IF;

    SET _i=_i+1;
END LOOP loop_words;

-- Clear up
CLOSE cursor_words;

END;;
DELIMITER ;
