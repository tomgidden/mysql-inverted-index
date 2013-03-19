/*
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This code is an _example_ implementation of the Inverted Index
 * Technique, coded using MySQL stored procedures and triggers.
 *
 * To run, create a mysql database, and then pipe this file (README.sql)
 * to the mysql command-line client:

       mysqladmin -u User -pPassword create invertedindex
       mysql -u User -pPassword invertedindex < README.sql

 * Alternatively, source the following SQL files, in order.  If you're at
 * the MySQL command prompt, do:
 */

\. sql/tables.sql
\. sql/sp_wordID.sql
\. sql/sp_wordID_withNew.sql
\. sql/sp_classID.sql
\. sql/sp_nextWord.sql
\. sql/sp_parseWords.sql
\. sql/sp_sanitizeWord.sql
\. sql/sp_indexString.sql
\. sql/sp_buildSearchParts.sql
\. sql/sp_search.sql
\. sql/sp_searchBasic.sql
\. sql/sp_searchPhrase.sql

-- -----------------------------------------------------------------------
-- and the sample data, which shows how to set up the correct triggers
-- -----------------------------------------------------------------------
\. tests/setup.sql
\. tests/triggers.sql
\. tests/data.sql

-- -----------------------------------------------------------------------
-- Then try out the searching procedures:
-- -----------------------------------------------------------------------
CALL searchBasic(classID('article'), 'night time');

CALL searchPhrase(classID('article.body'), 'best of times');

-- -----------------------------------------------------------------------
-- If you want to control the content output, then use the main 'search'
-- procedure directly:
-- -----------------------------------------------------------------------
CALL search(classID('article.body'), 'best of times', 'phrase',
                    'article', 'article_id', 'title,body');

CALL search(classID('article.body'), 'best of times', 'phrase',
                    NULL, NULL, NULL);

-- -----------------------------------------------------------------------
-- or run some of the "manual" SQL queries instead:
-- -----------------------------------------------------------------------
\. tests/query1.sql

\. tests/query2.sql

\. tests/query3.sql

\. tests/query4.sql

-- -----------------------------------------------------------------------
-- The SQL the stored procedures used is preserved in @_sql, so you can
-- see how the query works:
-- -----------------------------------------------------------------------
CALL searchPhrase(classID('article'), 'best of times');
SELECT @_sql;

-- -----------------------------------------------------------------------
-- The components of the query are also preserved, so you can construct
-- more complex queries.  You can prevent this by setting
-- @_suppressGlobals = TRUE.
-- -----------------------------------------------------------------------
SELECT CONCAT('SELECT ',@_outputFormat,
              ' FROM ',@_froms,
              ' WHERE ',@_wheres,
              ' GROUP BY ',@_groupBy,
              ' ORDER BY d.title') AS sql_from_parts;

-- -----------------------------------------------------------------------
-- If you set @_noExecute, then the query isn't actually executed, so you
-- can construct your own custom query.
-- -----------------------------------------------------------------------
SET @_noExecute = TRUE;
CALL searchPhrase(classID('article'), 'best of times');
SET @_noExecute = FALSE;

-- -----------------------------------------------------------------------
-- These functions can come in handy when using PREPARE and EXECUTE.
-- tests/query0.sql demonstrates this technique.
-- -----------------------------------------------------------------------
\. tests/query0.sql

-- -----------------------------------------------------------------------
-- If a word in a search string isn't found, then the result format is
-- different.
-- -----------------------------------------------------------------------
CALL searchPhrase(classID('article'), 'sadkhfasiuodyfaiusdhfaids');


/*
 * You can also try some of the bigger example files in the 'corpus' branch
 * (in SVN).  This is a much larger dataset sourced from Project Gutenberg
 * that takes longer to install, but gives a good test of the search
 * functions.
 *
 *
 * Notes:
 *
 * Column indexing these tables is critical.  It's worth taking a good
 * look at this with real data.  The sample data here will not demonstrate
 * correct indexing.
 *
 * Try out a few of the "CREATE INDEX search_index" lines in
 * sql/tables.sql, and see if they improve performance: Do a sample query
 * (using CALL searchBasic(...)), then SELECT @_sql, then DESCRIBE the
 * resulting query to see if the new index was used (by looking in the
 * 'key' column)
 *
 * Extra indexes can significantly slow down indexing time, but if they
 * are used, they may massively improve query performance.  The best thing
 * to do is try them out!
 *
 *
 * This implementation currently processes words in a very simple way: it
 * just trims whitespace from the start and end of the word, and it
 * converts it to lowercase.
 *
 * Words are considered to follow the pattern: [[:alnum:]]+, ie. a string
 * of alphanumeric characters.
 *
 * Different applications of this code will need different rules.
 * Addresses, in particular, have some specific needs, such as converting
 * ordinals (1st <=> First); adding alternatives (Basement Flat <=> Garden
 * Flat); abbreviations (ave. <=> Avenue).
 */
