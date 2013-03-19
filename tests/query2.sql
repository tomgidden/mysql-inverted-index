/*
 * Example query 2: Exact-AND
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This query will search for complete words in any order.
 */

SELECT a.*
FROM article a
     INNER JOIN search_index i1 ON i1.id = a.article_id
     INNER JOIN search_index i2 ON i2.id = a.article_id
WHERE
     i1.word_id = wordID(sanitizeWord('good'))
AND  i2.word_id = wordID(sanitizeWord('evil'))
GROUP BY a.article_id;