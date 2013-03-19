/*
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 */

-- Okay, this doesn't give great results, but it's a start...

SELECT DISTINCT wP.string as parent, wC.string as child
FROM       search_index AS iB
INNER JOIN search_index AS iP ON iB.id = iP.id
INNER JOIN search_index AS iC ON iB.id = iC.id
INNER JOIN word AS wP         ON wP.word_id = iP.word_id
INNER JOIN word AS wC         ON wC.word_id = iC.word_id
WHERE
    iP.position = iB.position - 1
AND iC.position = iB.position + 1
AND iC.search_class_id = classID('bibleverse')
AND iB.search_class_id = classID('bibleverse')
AND iP.search_class_id = classID('bibleverse')
AND iB.word_id IN (wordID(sanitizeWord('begat')),
                   wordID(sanitizeWord('beget')))
ORDER BY parent;
