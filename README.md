# Citations Graph database (Neo4j)

### Purpose
We created a graph database in Neo4j and via Neo4j browser, we imported the dataset and wrote queries using Cypher scripting language, which is supported by Neo4j. 

### Dataset
The data were derived from the DBLP citation network, which contains authors, articles, venues and citations between articles. 
The dataset can be downloaded from: 

https://drive.google.com/file/d/1bFEB_GxhPXT-xWEbK8hCUrR-TjdnqlYv/view?usp=sharing


The dataset consists of the following csv files: 
* ArticleNodes.csv: Contains info about Article nodes (id, title, year, abstract). 
* AuthorNodes.csv: Contains the names of the authors. 
* VenueNodes.csv: Contains the names of the venues. 
* AuthorShipRels.csv: Contains info about the relationships between articles and authors (articleId, authorName). 
* CitedRels.csv: Contains info about citations between articles (articleId, --[Cites]->, articleId). 
* PublishsRels.csv: Contains info about the relationship between venues and articles (articleId, venueName)

