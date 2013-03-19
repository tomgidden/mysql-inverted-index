DROP PROCEDURE IF EXISTS parseWords;

DELIMITER ;;

CREATE PROCEDURE parseWords (in_string TEXT) MODIFIES SQL DATA
thisproc:BEGIN

DECLARE pos			  INT DEFAULT 0;
DECLARE string_length INT DEFAULT length(in_string);
DECLARE capture		  INT DEFAULT NULL;
DECLARE buf			  VARCHAR(128) DEFAULT NULL; -- word buffer
DECLARE chr			  VARCHAR(1);


-- Creates temporary table for storing and the retrieval of
-- results. This table can in the future be joined against a set of
-- conversions (1st=>First) etc.

DROP TEMPORARY TABLE IF EXISTS parseWords_result; -- (potentially) dangerous.
CREATE TEMPORARY TABLE parseWords_result(
	   pos int primary key auto_increment,	-- auto inc is used here for automatic
						-- word position enumeration
	   word varchar(128)
);

-- Iterates over each character in the in_string
REPEAT
	SET chr =  substr(in_string, pos,1);
	IF chr is NULL THEN
	   LEAVE thisproc;
	END IF;

	SET capture = IF(chr REGEXP '^[a-zA-Z0-9]$', 1, NULL);

	IF (capture = 1) THEN
	   SET buf =  IF(buf is NULL, chr, concat(buf,chr));
	END IF;


	IF ((capture IS NULL OR pos = string_length) AND buf IS NOT NULL) THEN
	   INSERT INTO parseWords_result (word) VALUES (buf);
	   SET buf = NULL;
	END IF;

	SET pos=pos+1;
UNTIL pos > string_length
END REPEAT;
END ;;



DELIMITER ;
