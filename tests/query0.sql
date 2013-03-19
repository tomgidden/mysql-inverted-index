/*
 * Example query 0: Building a complex query
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This query will list the frequency of the word "the" in each article.
 */

SET @_noExecute = TRUE;
CALL search(classID('article'), 'the', 'and', 'article', NULL, NULL);

SET @bigSQL = CONCAT('SELECT d.title, COUNT(*) AS occurrences_of_the',
                     ' FROM ',@_froms,
                     ' WHERE ',@_wheres,
                     ' GROUP BY ',@_groupBy,
                     ' ORDER BY d.title');

PREPARE bigQuery FROM @bigSQL;
EXECUTE bigQuery;
DROP PREPARE bigQuery;

SET @_noExecute = FALSE;
