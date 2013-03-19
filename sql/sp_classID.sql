/*
 * classID
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 */

DROP FUNCTION IF EXISTS classID;
DELIMITER ;;

CREATE FUNCTION `classID`(_className VARCHAR(64)) RETURNS INT UNSIGNED
    DETERMINISTIC
    READS SQL DATA

/*
 * Returns the search_class_id from the search_class table for a given
 * class name, if found
 */

BEGIN

DECLARE _classId INT UNSIGNED DEFAULT 0;

SELECT search_class_id INTO _classId FROM search_class WHERE name = _className;

RETURN _classId;

END;;
DELIMITER ;
