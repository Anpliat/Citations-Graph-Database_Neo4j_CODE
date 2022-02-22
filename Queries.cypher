// Nodes: 
// Article {id,title,year,abstract}    |    Authors {name}    |   Venues {name}

// Relationships:
// MERGE (a)-[:WRITES]->(p);      // an author writes an article (AuthorShipRels)
// MERGE (p)-[:PUBLISHED]->(v);  // an article published to an venue (PublishsRels)
// MERGE (p1)-[:CITES]->(p2);   // (CitedsRels)

// ####### Which are the top 5 authors with the most citations (from other papers). Return author names and number of citations. 

// 1st solution
// An author WRITES an article and from the acrticles writen give me those that are cited by other articles
// We can match arrows either way

MATCH (n:Authors)-[:WRITES]->(a1:Article)
MATCH (a1:Article)<-[:CITES]-(a2:Article)    // access the nodes in reverse to a relationship (reverse direction)
RETURN n.name AS Author_Name, COUNT(a2) AS citation_count
ORDER BY citation_count DESC
LIMIT 5

// 2nd solution
MATCH (n:Authors)-[:WRITES]->(b:Article)
MATCH (a:Article)-[:CITES]->(b:Article)
RETURN n.name AS Author_Name, COUNT(*) AS citation_count
ORDER BY citation_count DESC
LIMIT 5

// -------------------------------------------------------------------------------------------------

// ####### Which are the top 5 authors with the most collaborations (with different authors). Return author names and number of collaborations. 

// WITH: manipulate the output before it is passed on to the following query parts. 
// collect(): gives you the capability to aggregate values into a list. 
// You can use this to group a set of values based on a particular starting node, relationship, property.
// Counting Values in a List
// If you have a list of values, you can also find the number of items in that list 
// or calculate the size of an expression using the size() function.
// COLLECT: collects values into a list (a real list that you can run list operations on).

MATCH (author:Authors)-[:WRITES]->(a1:Article)
MATCH (coauthor:Authors)-[:WRITES]->(a2:Article)
WITH a1,a2,author, coauthor
WHERE a1.id = a2.id AND  author.name <> coauthor.name
RETURN author.name AS Author_Name, size(COLLECT(DISTINCT coauthor.name)) AS collaborations_number
ORDER BY collaborations_number DESC
LIMIT 5

// -------------------------------------------------------------------------------------------------

// ####### Which is the author who has wrote the most papers without collaborations. Return author name and number of papers. 

// 1st solution
MATCH (author:Authors)-[r:WRITES]->(a1:Article)
MATCH (coauthor:Authors)-[:WRITES]->(a1:Article)
WITH a1,author, coauthor
WHERE author.name = coauthor.name
WITH author, a1,collect(coauthor.name) as collaborates, size(collect(coauthor.name)) AS collaborations_number
WHERE collaborations_number = 1
RETURN author.name as Author_Name, COUNT(a1) AS count
ORDER BY count DESC
LIMIT 1

// 2nd solution
MATCH (author:Authors)-[r:WRITES]->(a1:Article)
MATCH (coauthor:Authors)-[:WRITES]->(a1:Article)
WITH a1,author, coauthor
WHERE author.name = coauthor.name
RETURN author.name as Author_Name, COUNT(a1) AS count
ORDER BY count DESC
LIMIT 1

// -------------------------------------------------------------------------------------------------

// ####### Which author published the most papers in 2009? Return author name and number of papers. 
// year: yparxei san property ston Article Node (integer)

// 1st solution 
MATCH (a:Article{year:2009})-[:PUBLISHED]->(v:Venues)
MATCH (author:Authors)-[:WRITES]->(a)
RETURN author.name as Author_Name, COUNT(a) AS count
ORDER BY count DESC
LIMIT 1

// 2nd solution
MATCH (author:Authors)-[:WRITES]->(a:Article)
MATCH (a)-[:PUBLISHED]->(v:Venues)
WHERE a.year=2009
RETURN author.name as Author_Name, COUNT(a) AS count
ORDER BY count DESC
LIMIT 1

// -------------------------------------------------------------------------------------------------

// ####### Which is the venue with the most papers on the Data Mining field (derived from the paper title) in 2001. Return venue and number of papers. 

// WHERE a.title CONTAINS 'Data Mining'
// The CONTAINS operator is used to perform case-sensitive matching regardless of location within a string.
// For example: Contains will only recognise 'Data Mining' and NOT 'data mining'
// match on regular expressions by using =~ 'regexp',
// We used regular expressions to match a part of the article title

// 1st solution
MATCH (a:Article)
WHERE a.title =~ '(?i).*Data Mining.*' AND a.year=2001
MATCH (a)-[:PUBLISHED]->(v:Venues)
RETURN v.name as Venue_Name, COUNT(a) AS count
ORDER BY count DESC
LIMIT 1

// 2nd solution
MATCH (a:Article{year:2001})
WHERE a.title =~ '(?i).*Data Mining.*'
MATCH (a)-[:PUBLISHED]->(v:Venues)
RETURN v.name as Venue_Name, COUNT(a) AS count
ORDER BY count DESC
LIMIT 1

// -------------------------------------------------------------------------------------------------

// ####### Which are the top 5 papers with the most citations? Return paper title and number of citations

MATCH (a1:Article)-[:CITES]->(a2:Article)
RETURN a2.id as id, a2.title AS Paper_title, COUNT(a2) AS citation_number
ORDER BY citation_number DESC
LIMIT 5

// We also used article.id in order to avoid duplicate article names

// -------------------------------------------------------------------------------------------------

// ####### Which were the papers that use “Neural Networks” in “speech recognition” (derived from the paper abstract). Return authors and title. 

// 3503;Neural Networks and Soft Computing: Proceedings of the Sixth International Conference on Neural Network and Soft Computing
// Neural Network anti gia Neural Network-s!!!!

// 3868;Speech Recognition   => kai exw speech recognition.
// Pali pame gia case insesitive

MATCH (author:Authors)-[:WRITES]->(a:Article)
WHERE a.abstract =~ '(?i).*Neural Networks.*' AND a.abstract =~ '(?i).*speech recognition.*'
RETURN collect(author.name) as Author_Names, a.title as Paper_name
ORDER BY Paper_name      // for alphabetical order 

// collect(author.name): wste gia to idio paper na emfanizontai oloi oi Authors mazi
// AN DEN TO BALW: EMFANIZEI TO IDIO PAPER GIA KA8E AUTHOR POU TO EXEI GRAPSEI KSEXWRISTA. EGW 8ELW MIA FORA GIA KA8E PAPER

// -------------------------------------------------------------------------------------------------

// ####### Find the shortest path between ‘Rakesh Agrawal’ and ‘Donald E. Knuth’ authors. Return the length of the path and the paper titles of the path. 

// We have an unweighted graph
// Added 2 labels, created 2 nodes, set 2 properties
// a:Authors{name:'Rakesh Agrawal'}  // start node
// f:Authors{name:'Donald E. Knuth'}  // end node

// SHORTEST PATH
MATCH (a:Authors{name:'Rakesh Agrawal'}),(f:Authors{name:'Donald E. Knuth'}), p = shortestPath((a)-[*]-(f))
// MATCH p = shortestPath((a:Author{name:'Rakesh Agrawal'})-[*]-(f:Author{name:'Donald E. Knuth'}))
RETURN [n in nodes(p) | n.title] AS ShortestPath, length(p) as Length

// # Extra plot:
MATCH (a:Authors{name:'Rakesh Agrawal'}),(f:Authors{name:'Donald E. Knuth'}), p = shortestPath((a)-[*]-(f))
RETURN p

// -------------------------------------------------------------------------------------------------

// ####### Find all authors with maximum shortest path length 3 from author ‘Jeffrey D. Ullman’. Return the length and the paper titles for each path. 

// Variable-length pattern matching
// To describe paths of length 5 or less, use:
// (a)-[*..5]->(b)
// https://neo4j.com/docs/cypher-manual/current/syntax/patterns/#cypher-pattern-varlength

MATCH (f:Authors), p = shortestPath((c:Authors{name:'Jeffrey D. Ullman'})-[*..3]-(f:Authors))
Where f<>c 
RETURN [n in nodes(p) | n.title] AS ShortestPath, length(p) as Path_length
order by Path_length DESC

// -------------------------------------------------------------------------------------------------

// ####### Calculate the top-10 articles with the highest page rank using max iterations=20 and damping factor=0,85.
// ####### Return article title and page rank score (in the calculation use only article nodes and cited relationships. 

// Page Rank Unweighted
// create the graph and store it in the graph catalog.

// gds.graph.create: Creates a graph in the catalog using a Native projection.

//  installing the GDS library:  https://neo4j.com/docs/graph-data-science/current/installation/
// Graph Data Science Library

// Verifying installation
RETURN gds.version()

CALL gds.graph.create(
    'myGraph',
    'Article',   // Article Node
    'CITES'     // CITES Relationship
)

CALL gds.pageRank.stream('myGraph',
{ maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).title AS Article_title, score as PageRank_score
ORDER BY PageRank_score DESC, Article_title ASC
LIMIT 10
