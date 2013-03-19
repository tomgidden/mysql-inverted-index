/*
 * buildSearchParts
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This constructs the various clauses for the search query, returning
 * them in the INOUT parameters.
 *
 * It is not intended to be used directly, but by the "search" procedure.
 *
 * Parameters:
 *
 * _classId:   the class ID to be searched.  eg. classID('doc')
 *
 * _sentence:  the sentence to be searched.  eg. "best of times"
 *
 * _type:      'and', 'ordered' or 'phrase', to determine search type.
 *
 * _froms:     the resulting FROM clause.  Should start with the initial
 *             data table or i0 (see search procedure).  Set to NULL if
 *             no words will be found.
 *
 * _wheres:    the resulting WHERE clause.
 *
 */

DROP PROCEDURE IF EXISTS buildSearchParts;
DELIMITER ;;

CREATE PROCEDURE `buildSearchParts`(_classId INT UNSIGNED,
                                    _sentence TEXT,
                                    _type ENUM('and', 'ordered', 'phrase'),
                                    INOUT _froms TEXT,
                                    INOUT _wheres TEXT)
    DETERMINISTIC -- is this true?  Hrmm...
    READS SQL DATA
thisproc:BEGIN

-- Iterator counter for word loop
DECLARE _i INT UNSIGNED DEFAULT 0;

-- Found word
DECLARE _word TEXT;

-- ID for found word
DECLARE _wordId INT UNSIGNED;

-- Find the first word in the sentence
CALL nextWord(_sentence, _word);

-- Okay.  For each word...
WHILE (_word IS NOT NULL) DO

    -- Get the ID for this word
    SET _wordId = wordID(sanitizeWord(_word));

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

    -- Get the next word
    CALL nextWord(_sentence, _word);

END WHILE;

END;;
DELIMITER ;
