/*
 * searchBasic
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This constructs and executes a simple "AND" query, based on an input
 * string of words.  Rather than including the words themselves in the
 * query, it looks them up in advance.
 *
 * Parameters:
 *
 * _classId:   the class ID to be searched.  eg. classID('doc')
 *
 * _sentence:  the sentence to be searched.  eg. "best of times"
 *
 * Optional control variables:
 *
 *   SET @_noExecute = TRUE;
 *      -- Returns the query parts, rather than executing it, to assist
 *      -- building of custom queries.
 *
 *   SET @_suppressGlobals = TRUE;
 *      -- Do not set the global variable parts, and preserve @_sql if
 *      -- possible.
 *
 */

DROP PROCEDURE IF EXISTS searchBasic;
DELIMITER ;;

CREATE PROCEDURE `searchBasic`(_classId INT UNSIGNED, _sentence TEXT)
thisproc:BEGIN

DECLARE _dataTable VARCHAR(64);
DECLARE _primaryKey VARCHAR(64);

-- Retrieve data table from search_class table, so we know what to display.
SELECT data_table, primary_key
    INTO _dataTable, _primaryKey
    FROM search_class
    WHERE search_class_id = _classId;

IF _dataTable IS NULL THEN
    -- The search_class wasn't found, or the _dataTable was NULL (impossible?)
    SELECT CONCAT('Search class ',_classId,' not found or incomplete.') AS Error;
    LEAVE thisproc;
END IF;

CALL search(_classId, _sentence, 'and', _dataTable, _primaryKey, 'd.*');

END;;
DELIMITER ;
