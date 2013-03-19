/*
 * search
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This is the main searching procedure.
 *
 * Parameters:
 *
 * _classId:   the class ID to be searched.  eg. classID('doc')
 *
 * _sentence:  the sentence to be searched.  eg. "best of times"
 *
 * _type:      'and', 'ordered' or 'phrase', to determine search type.
 *
 * _dataTable: the name of the data table to return, eg. 'doc'.  If just
 *             the ids are required, then NULL.
 *
 * _primaryKey: the primary key of the data table to join the index
 *             against, eg. 'doc_id'
 *
 * _outputFormat: the list of columns to return in the query, or NULL to
 *             return all columns in the data table.
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

DROP PROCEDURE IF EXISTS search;
DELIMITER ;;

CREATE PROCEDURE `search`(_classId INT UNSIGNED,
                          _sentence TEXT,
                          _type ENUM('and','ordered','phrase'),
                          _dataTable VARCHAR(64),
                          _primaryKey VARCHAR(64),
                          _outputFormat TEXT)
    DETERMINISTIC
    READS SQL DATA
thisproc:BEGIN

--
-- Internal Variables
--
DECLARE _oldSql TEXT; --  To preserve @_sql if @_suppressGlobals.

-- The clause strings
DECLARE _froms TEXT DEFAULT '';
DECLARE _wheres TEXT DEFAULT '';
DECLARE _groupBy TEXT DEFAULT '';

-- Initialise the SQL query string
IF (_dataTable IS NOT NULL) THEN
    -- A data table name was supplied, so we need to process it and start
    -- the query with that table.

    IF (_primaryKey IS NULL) THEN
        -- No _primaryKey specified, so we use the data table name, and
        -- put _id on the end.
        SET _primaryKey = CONCAT(_dataTable, '_id');
    END IF;

    IF (_outputFormat IS NULL) THEN
        -- No output format, so we just get the complete data row.
        SET _outputFormat = 'd.*';
    END IF;

    IF (_dataTable REGEXP '^[[:alnum:]_]+$') THEN
        -- _dataTable is a simple identifier, so we'll need to alias it to
        -- "d".  If _dataTable is more complex, we just pass it as-is, and
        -- assume the user knows what they're doing.
        SET _dataTable = CONCAT(_dataTable, ' AS d');
    END IF;

    -- Start the _froms string
    SET _froms = CONCAT(_dataTable,
                       ' INNER JOIN search_index i0 ON d.',
                       _primaryKey,'=i0.id');
ELSE
    -- No data table name was supplied, so we won't bother with a data
    -- table and just act on the index.
    SET _primaryKey = 'id';
    SET _dataTable = 'search_index i0';

    IF (_outputFormat IS NULL) THEN
        -- No output format, so we just get the indexed id
        SET _outputFormat = 'i0.id';
    END IF;

    -- Start the _froms string
    SET _froms = 'search_index i0';
END IF;

-- We can group by i0.id regardless of the data table.
SET _groupBy = 'i0.id';

-- Build the query
CALL buildSearchParts(_classId, _sentence, _type, _froms, _wheres);

IF (@_suppressGlobals) THEN
    -- This time, the user has requested suppression of the global parts.
    -- However, we need to set @_sql as PREPARE will not work on local
    -- variables.  We assume @_sql is TEXT, but can't be sure,
    -- unfortunately.
    SET _oldSql = @_sql;
ELSE
    -- Expose the query parts so the user can construct new queries.
    SET @_outputFormat = _outputFormat;
    SET @_froms = _froms;
    SET @_wheres = _wheres;
    SET @_groupBy = _groupBy;
    SET @_dataTable = _dataTable;
    SET @_primaryKey = _primaryKey;
END IF;

IF (_froms IS NULL) THEN
    -- The query builder found an unrecognised word, so we should
    -- terminate here.
    IF NOT (@_suppressGlobals) THEN
        SET @_outputFormat = NULL;
        SET @_froms = NULL;
        SET @_wheres = NULL;
        SET @_groupBy = NULL;
        SET @_dataTable = NULL;
        SET @_primaryKey = NULL;
        SET @_sql = NULL;
    END IF;
    SELECT CONCAT("Word '",_wheres,"' not found") as Error;
    LEAVE thisproc;
END IF;

-- Construct query SQL
SET @_sql = CONCAT('SELECT ', _outputFormat,
                   ' FROM ', _froms,
                   ' WHERE ', _wheres,
                   ' GROUP BY ', _groupBy);

IF (@_noExecute) THEN
    -- No query execution is required, so we just output the parts.
    SELECT _outputFormat AS outputFormat,
           _froms AS froms,
           _wheres AS wheres,
           _groupBy AS groupBy,
           _dataTable AS dataTable,
           _primaryKey AS primaryKey;
ELSE
    -- Execute the query
    PREPARE query FROM @_sql;
    EXECUTE query;
    DROP PREPARE query;
END IF;

-- Restore @_sql if requested.
IF (@_suppressGlobals) THEN
    SET @_sql = _oldSql;
END IF;

END;;
DELIMITER ;
