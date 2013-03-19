/*
 * Tables
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 */


DROP TABLE IF EXISTS search_index;
DROP TABLE IF EXISTS search_class;
DROP TABLE IF EXISTS word;

/*
 * This table contains a list of words as used in the search index.
 */
CREATE TABLE word (
  word_id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  string VARCHAR(128) NOT NULL,
  PRIMARY KEY (word_id),
  UNIQUE KEY (string)
);

/*
 * This table contains a list of search classes.
 */
CREATE TABLE search_class (
  search_class_id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(64) NOT NULL,
  data_table VARCHAR(64) NOT NULL,
  primary_key VARCHAR(64) NOT NULL,
  columns VARCHAR(255),
  PRIMARY KEY (search_class_id),
  KEY (name)
);

/*
 * This table contains the search index.  It's difficult to guess what
 * indexes to put on this table, but it's clear that good indexing is
 * vital for this table in particular.
 */
CREATE TABLE search_index (
  id INT(10) UNSIGNED NOT NULL,
  search_class_id INT(11) UNSIGNED NOT NULL,
  position INT(10) UNSIGNED NOT NULL,
  word_id INT(10) UNSIGNED NOT NULL,

  PRIMARY KEY (id,search_class_id,position),
  FOREIGN KEY (word_id) REFERENCES word (word_id),
  FOREIGN KEY (search_class_id) REFERENCES search_class (search_class_id)
);

/*
 * More indexes slows down index creation (and update) time significantly,
 * but _can_ speed up query time even more significantly.  Use "SELECT
 * @_sql" and then DESCRIBE the resulting query to work out what indexes
 * are being used, and drop the others.
 *
 * The "wcp" index appears to be the most important, but the others are
 * worth evaluating.
 */

CREATE INDEX wcp ON search_index (word_id, search_class_id, position);
CREATE INDEX iwc ON search_index (id, word_id, search_class_id);
CREATE INDEX icw ON search_index (id, search_class_id, word_id);
/*
CREATE INDEX cwp ON search_index (search_class_id, word_id, position);
CREATE INDEX cpw ON search_index (search_class_id, position, word_id);
CREATE INDEX cip ON search_index (search_class_id, id, position);
CREATE INDEX cpi ON search_index (search_class_id, position, id);
CREATE INDEX pci ON search_index (position, search_class_id, id);
CREATE INDEX pic ON search_index (position, id, search_class_id);
*/
