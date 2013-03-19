mysql-inverted-index
====================

Originally on https://code.google.com/p/inverted-index/

This project aims to create a toolkit providing DBAs and programmers with a simple way of querying and updating an inverted index, initially supporting MySQL 5. The index is stored as wordlist tables in the database itself, and thus requires no additional software for searching and index creation.

This is, in effect, an alternative to MySQL's FULLTEXT mechanism, or the dreaded "WHERE word LIKE '%foo%'" construction. While it doesn't offer the power of a dedicated search library, it is simple and self-contained.

***

Rather than a long-winded pompous manifesto, here's the initial chat thread between Tom and Stig.  It should give you some idea of the aim of the project:

----
_Tom Gidden_:

I just wrote a bunch of stored procedures and triggers, to try to make some of the inverted index stuff more transparent... not that it's a panacea, but it's a darn sight better than LIKE %foo%.

This week alone, I've had to debug three completely independent projects which have relied on wildcard-leading LIKEs. It amazes me that so-called SQL developers don't realise how wrong it is.

----
_Stig Palmquist_:

Wanna create an Open Source project of out it? It might be a viable alternative to {p,c,}lucene, swish, etc.
 
----
_Tom Gidden_:

It is tempting... I was considering writing it up as a blog post. I guess time is the limiting factor!

While it's nowhere near as powerful as a "proper" search library as you say, I think it's still useful for small-scale stuff and when you need to do keyword searches combined with other criteria.

The worst thing is that there are so many developers who have no idea that "%foo%" is a bad thing and that there's an alternative!

The other day, I had to work on some SQL queries containing:

pstatus LIKE "%%" AND
pdesc LIKE "%%" AND
(paddr1 LIKE "%%" OR
paddr2 LIKE "%%" OR
paddr3 LIKE "%%" OR
paddr4 LIKE "%%" OR
paddr5 LIKE "%%")

!!!
 
----
_Stig Palmquist_:

Yes, double-ended wildcard likes creates all kinds of problems, but is very common due to it being too easy to implement. Unfortunately (of fortunately from a consultants perspective) it's rarely fixed before the queries fall over on themselves under high load and/or the table growing too large.

But, the alternatives (apart from the dodgy FULLTEXT index in MySQL) are usually too "hard" to implement. And people rarely need the flexibility of a proper search engine. So that's why I'm kinda excited about your stored procedures as they would be a part of a self contained solution existing in the database requiring no additional application side hacks. You could also implement incremental indexing etc. using triggers, and the search could (i think) be returned by a stored procedure generating the SQL needed and returning a dataset that can be and joined against other stuff (although I'm uncertain of the last part).

I was looking at Sphinx Search which has a full MySQL backend integration; meaning that you can join on the result of a query against the index. :D Quite exciting stuff, but not trivial to set up and lacked some essential features like date range matching, matching on different attributes, etc.

----
_Tom Gidden_:

The problem with the stored procedure approach is that it's pretty much impossible to genericise the search itself without using iterative temporary tables (bad for optimisation), as you can't build a SELECT query dynamically in an SP. As you say, it is possible to have a stored procedure which returns an SQL string to execute, but that's just plain yicky! :)

However, just having the indexing task trigger-driven does ensure it's kept up-to-date, I suppose.

I did make the case that while it is necessary to always keep the index complete and up-to-date, you don't have to always use it... it's possible to use the inverted index for some queries and not others. So, having the actual search SELECT query SP'ed is less necessary.

As a side-point, it's also beneficial for the stored procedures to be customised per function: firstly, because the triggers and indexing SPs need to be customised to particular column and table names, and secondly, to allow application-specific word processing (eg. word stemming; conversion of 1st=>First; junk removal)

I think what would be most useful is a CPAN (and secondarily, PEAR) module generates the appropriate tables, SPs and triggers, and will also build search queries (and also query fragments, eg. ($joins, $wheres) ) on the Perl side too.

On a project I did a while back, I wrote a "Search" object, which I subclassed twice: once with this technique, and once to make use of FULLTEXT. That way, I could compare the two without any app changes.

The thing about external engines is that while they're so much faster, and sometimes totally necessary, they really tie your hands when it comes to choices like replication, backups, etc... all your decisions get decided by how things work with the external library. The virtue of the 100% SQL approach is that while it's slow and not particularly scalable, it's _totally_ self-contained and engine independent. It's almost RDBMS-independent.

Is there already a CPAN module for search query building? Damn well should be... hrm. Now that would be something we could put together quite nicely...
 
----
_Stig Palmquist_:

I would never suggest returning a generated SQL query thought, but rather generate it inside the procedure, use "PREPARE statement" to prepare it with placeholders and then executing the query with the appropriate values with "EXECUTE statement USING var1, var2, var3". This should work in stored procedures, but not in functions or triggers.

Unfortunately, MySQL does not have an array type, but a temp table could be used as a stack to populate the argument list in some fashion.

When it comes to customising of the procs per table, it might not be necessary if the index itself is normalised to include the identifiers, and the query can be generated using PREPARE.

Since MySQL lacks the ARRAY type altogether, it seems difficult to go down this route though as you must create either create UDF extensions or find a good way of getting around this. As you suggested, generating code using Perl/PHP/whatever might prove to be easier;

You should have a look at the DBIx::Class modules, There are several abstraction layers there that might provide a good starting point for writing such modules (and making them portable across different engines).

I've been thinking about writing something that generates and updates nested sets from adjacency lists as a CPAN module myself.

... and a project aiming to implement the searching and indexing technique would certainly attract some attention, as well as contributions from developers. I would certainly use it, as well as probably hack on it. :-)

----
_Tom Gidden_:

Thinking a bit more about the idea of doing it all in SPs..

The SPs themselves would be quite horrific. You'd need one that would take a table and list of columns and would generate all of the CREATE TABLEs for the indexes, the triggers, indexing SPs, search SP generators, and so forth. All that would have to be manually cut-and-pasted back into the MySQL client.

I don't know whether that would be easier than just having a Perl script to generate that stuff for you, and either echo it to be piped to the mysql CLI, or applied directly using -u, -h, and -p

(thinks)

I mean, there is a certain neatness to having _everything_ done in MySQL, but there's a balancing act of that elegance verses the extreme messiness of the code itself :)

What do you think?
 
You say you'd never suggest returning a generated SQL query... well, I've seen it done in fairly big Sybase and MSSQL projects, even though it's gross.

I'd forgot about server-side prepped statements, to be honest... good point!

That might actually work quite well.... the indexer itself doesn't need to generate SQL, so the prohibition against PREPARE in triggers and functions wouldn't be a problem.

The queryer can build and PREPARE the query, returning the name. It can then just be EXECUTEd by hand with the correct params. Hrm... can a prepared statement DROP itself on completion?

IIRC, PREPARE/EXECUTE can't be used to generate SPs, can it? That's a bit annoying.

At the very least, the ability to build the search query on the server rather than in Perl/PHP could be very useful.

You've got my brain working now... MAKE IT STOP! ARGH!
 
----
_Tom Gidden_:

Hrm...

I suppose it's probably worth having a project that actually offers all of these techniques:

1. An all-in-one that uses a single normalised index, and no customised SPs.

2. A perl script to generate the right SPs for a more customised approach

3. A more application-side module (eg. CPAN/PEAR)

...rather than trying to prescribe a single method.

Google Code project, then? :)
 
----
_Stig Palmquist_:

Let's get it on!

I'm unsure if it is possible to do create a SP in an SP, code generation is interesting.

I agree that the project could aim to deliver the three points you mentioned. Should the initial scope be #1? I.e. create the indexing and searching mechanisms working off one table to start - and then later expanding it to support multiple tables and column?

How does "mysql-inverted-index" sound as a name?

Or "Mii"? :)

----
_Tom Gidden_:

Yep... agree with starting with #1.

Even if we progress to an all-singing-all-dancing multi-table version, #1 is still useful as a simpler, tighter alternative.

I don't think you can create SPs in SPs, and while you might be able to create triggers in SPs (although I think not), you can't parameterise the table names inside. So, the triggers themselves would have to be manually installed.

Still, I think a fairly neat toolkit could be built: the project would basically be a small set of procs and a nice, easy "fill-in-the-blanks" HOWTO.

Just for delusions of grandeur, let's miss out the "mysql" bit from the name :) Maybe just "Inverted-Indexing"? This should be applicable to other DBs.

----
_Stig Palmquist_:

The SP could potentially create the trigger by using something like "SET @statement := CONCAT('CREATE TRIGGER ', trigger_name, ' blablablah);" 

And to make it easier to use, we could create some kind of perl script that automatically creates the procs with the correct table/column names too. :)

