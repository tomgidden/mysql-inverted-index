/*
 * Tables
 * Inverted Index Toolkit  <http://code.google.com/p/inverted-index/>
 * Apache License 2.0, blah blah blah.
 */


DROP TABLE IF EXISTS article;

/*
 * This table is a simple article table
 */
CREATE TABLE IF NOT EXISTS article (
  article_id INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  title text NOT NULL,
  author text NOT NULL,
  body text NOT NULL,
  PRIMARY KEY  (article_id)
);

