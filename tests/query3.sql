/*
 * Example query 3: Phrase searching
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This query will search for a specific phrase.
 */

SELECT a.*
FROM article a
     INNER JOIN search_index i1 ON i1.id = a.article_id
     INNER JOIN search_index i2 ON i2.id = a.article_id
     INNER JOIN search_index i3 ON i3.id = a.article_id
WHERE
     i1.word_id = wordID(sanitizeWord('bore'))

AND  i2.word_id = wordID(sanitizeWord('golden'))
AND  i2.position = i1.position + 1
AND  i2.search_class_id = i1.search_class_id

AND  i3.word_id = wordID(sanitizeWord('apples'))
AND  i3.position = i2.position + 1
AND  i3.search_class_id = i2.search_class_id

GROUP BY a.article_id;
