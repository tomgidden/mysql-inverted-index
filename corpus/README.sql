/*
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 *
 * This directory contains a sample text corpus, consisting of "Moby
 * Dick", "War and Peace", and the King James Bible, courtesy of Project
 * Gutenberg.  The Bible is stored twice: in the doc table per chapter,
 * and also in the bibleverse table by chapter,verse.  This demonstrates
 * the use of the library on smaller rows.
 *
 * As the content is quite large, it can take some time to index.
 *
 * To install, first install the main inverted-index distribution.
 * Then, either pipe this file to the mysql command-line client, or
 * manually source the following SQL files, in order.  If you're at the
 * MySQL command prompt, do:
 */

SELECT 'Setup...' AS Status;
\. setup.sql

SELECT 'Indexing "War and Peace"...' AS Status;
\. war_and_peace.sql

SELECT 'Indexing "Moby Dick"...' AS Status;
\. moby_dick.sql

SELECT 'Indexing "Bible as Documents"...' AS Status;
\. bibledoc.sql

SELECT 'Indexing "Bible as Verses"...' AS Status;
\. bibleverse.sql

-- ----------------------------------------------------------------------
-- and then you can try:
-- ----------------------------------------------------------------------
CALL searchPhrase(classID('doc.body'), 'good and evil');

-- ----------------------------------------------------------------------
-- The included "query_begat.sql" demonstrates how you can use the data in
-- other interesting ways, albeit with varying levels of success...
-- ----------------------------------------------------------------------
\. query_begat.sql
