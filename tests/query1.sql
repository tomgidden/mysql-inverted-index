/*
 * Example query 1: Single exact word lookup
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This query will search for a complete word in the "body" field only.
 */

SELECT a.*
FROM article a
     INNER JOIN search_index i1 ON i1.id = a.article_id
WHERE
     i1.word_id = wordID(sanitizeWord('good'))
AND  i1.search_class_id = classID('article')
GROUP BY a.article_id;