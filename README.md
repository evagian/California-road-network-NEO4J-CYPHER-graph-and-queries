# 1. Introduction
Aim of this project is to get hands on experience on NEO4J and CYPHER.
The dataset used for this assignment contains California’s road networks and points of interest. To be more precise the dataset consists of crossroads, roads connecting one crossroad to another and points of interest which are located in the road network. Each road may contain from none to several points of interest.
For this project purposes we transformed the dataset, we designed and created a graph database, we then loaded the dataset into the graph and finally we performed queries in order to answer specific questions. In this report we will describe in more detail the procedure which was mentioned above.

# 2. Dataset
We used an open source dataset provided by the University of Utah. This dataset consists of 6 separate files.
California Road Network's Nodes and can be found here:

https://www.cs.utah.edu/~lifeifei/SpatialDataset.htm

## California Road Network's Nodes

This file contains crossroads which are characterized by their unique id, and their coordinates.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/1.png)

## California Road Network's Edges
This file represents roads connecting one crossroad to another. Each road is described by a unique id, its length and two crossroads, the crossroad from where it begins and the one to which it ends

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/2.png)

## California's Points of Interest
This file represents points of interest found in the road network. More specifically each point of interest is described by a unique id and its coordinates.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/3.png)

## California's Points of Interest with Original Category Name
This file contains the name of the category in which each one of the points of interest belong.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/4.png)

## Merge Points of Interest with Road Network--Map Format
Finally, this file links the file containing the points of interest to the one containing the roads. It actually maps the location of each point of interest on the network. The first four attributes describe one specific road and the attributes which follow describe the points of interest located in the specified road. Each road is described by its start node, end node, length and its number of POIs. Meanwhile, for roads with number of POIs greater than zero this file contains information about each POI category and its distance from the start node.

File format before transformation
For each edge: 
Start Node ID, End Node ID, Number of Points on This Edge, Edge Length. 
    For each point on this edge: 
    Category ID, Distance of This Point to the Start Node of This Edge

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/5.png)

The format of this file was tricky and we had to transform it into two files in order to load it into the graph. Python was used for this purpose. In the resulted format each separate row describes exactly one POI and the road in which this point is located.

Format of the 2 files which were formed after the dataset’s transformation

● For each POI:
  ○ Edge Start Node Id , Category id , Distance
● For each number of Points of interest per road :
  ○ Edge Start Node Id , Edge End Node Id, Number of Pois

# 3. Model
The particularity of NEO4J is the fact that the design of the graph database is very flexible and it can completely adapt in the needs of each dataset. Thus, when designing the graph database we should take into consideration the nature of our dataset as well as the queries that we will need to perform.

We designed a directed graph consisting of 2 types of nodes and 2 types of edges. More specifically, we used nodes to represent the crossroads. Each crossroad had 3 properties, the crossroad’s unique id and coordinates (longitude and latitude). Roads were represented by directed edges. ROAD edges linked pairs of CROSSROAD nodes and contained 3 properties, the road id, the length of the road and the number of POIs in each road. Nodes named POI_CATEGORY were also used to describe POIs. These nodes contained 2 properties, POI category id and POI category name. POI_CATEGORY nodes were linked to the starting node of the road which they belonged through directed edges named HAS_POI. HAS_POI edges contained information concerning the distance of each poi from the start node of the road where they belong.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/6.png)

# 4. Data loading
After the design was finished we actually created the graph database on NEO4J according to what we have planned.

## 4.1. Load CROSSROAD nodes
Our first step was to create a unique constraint on the crossroad id. The same will be done for all the ids in the graph in order to make sure that each key will identify a unique record. Due to the fact that importing large amounts of data using LOAD CSV with a single Cypher query may fail due to memory constraints, we decided to use PERIODIC COMMIT. PERIODIC COMMIT processes specific number of rows at a time, while preventing running out of memory. PERIODIC COMMIT will also be used while loading all the other data files.

The first file to be loaded contained information about the crossroads and it was loaded into the CROSSROAD nodes. We used LOAD CSV for loading the nodes.csv file, headers included. The file was read line by line and each row was split into commas. We were able to refer to each column using line. followed by the specified csv column name. MERGE was used for creating the CROSSROAD nodes and the id, long and lat properties.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/7.png)

## 4.2. Load ROAD edges
Like before, we created a unique constraint on the road id and used PERIODIC COMMIT. Then we loaded the csv containing the roads and used it in order to create ROAD edges connecting pairs of CROSSROAD nodes. For each ROAD edge we linked the id of the crossroad from where the road begins to the id of the crossroad to where it ends. Each ROAD edge contained the road id and the length of the road.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/8.png)

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/9.png)

## 4.3. Load POIs
To load points of interest in our graph database we employ the use of python to convert provided data into a useful format.
To match category names with category ids we used excel feature of vlookup to match each category name to the respective category id. This file we named POI-name-id.csv and was imported in neo4j after the addition of points of interest in our graph database.

Next, we created nodes named POI and then we loaded has_poi.csv. POI nodes contained the category name and id in which the specified poi belongs. For matching POIs with start CROSSROADS we used the cat_id and start_node columns accordingly which were available in the file has_poi.csv. POI nodes were linked to the start nodes of the road in which they were located. This link was named HAS_POI and contained a property with the distance of the POI from the start node. We also added a new property to the ROAD relationship named number_of_poi, containing the number of POIs located in road of the relationship.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/10.png)
Figure 3 represents an example of how POI nodes were linked to the start CROSSROAD node of the ROAD relationship where they belong.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/11.png)
Figure 3 POI nodes and HAS_POI edges

## 4.4. Final graph
Figure 3 represents a small part of the final graph which was created in NEO4J.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/12.png)
Figure 4 Final graph

# 5. Queries
## 5.1. 1st query
Which crossroad has the most points of interest and in which category do they belong (category name and number of pois for every category)? Sort them in descending order?

During the first part of the query, for each CROSSROAD node we counted the number of HAS_POI edges starting from this CROSSROAD node. Then in the second part for each HAS_POI edge of every node we collected the category names of the connected POI nodes.

We used COLLECT and UNWIND clauses in order to perform the union between the property category_name of POI node and the degree, or number of HAS_POI edges starting from each node. The 1st part returned a sorted list in descending order containing the node id and number of pois of this node. In the second part of the query we added the category name in the already sorted list of nodes with pois.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/13.png)

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/14.png)

## 5.2. 2nd query
Which is the shortest path between crossroads with id:10 and id:16?

This query calculates and returns the shortest path and the length of the shortest path between the 2 specified nodes. This query also answers the 3rd query, which asks ‘Find the total distance of the shortest path from query 2.’

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/15.png)

## 5.3. 3rd query
Find the total distance of the shortest path from query 2.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/16.png)

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/17.png)

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/18.png)


## 5.4. 4th query
Find the top three crossroads with the most bars.

We first had to find all the CROSSROAD nodes which were connected to at least one POI with category name ‘BAR’. For each of these CROSSROADS we counted the number of HAS_POI edges which lead to BAR POI. Finally, the query returned a list with the ids of these CROSSROAD node followed the count of BAR POIs. This list was ordered by the number of bars in descending order and only the first 3 rows were kept.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/19.png)

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/20.png)

## 5.5. 5th query
Which is the shortest path between crossroads with id:10 and id:21 which passes through crossroad with id:17?

This query calculates the shortest path between crossroads with id:10 and id:17 as path1 and crossroads with id:17 and id:21 as path2. It then calculates the sum of the lengths of path1 and path2 and names it as length. It sorts the results in length’s descending order and only keeps the first row which contains the shortest path between crossroads with id:10 and id:21 which passes through crossroad with id:17. Finally it prints the shortest path and its length.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/21.png)

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/22.png)

## 5.6. 6th query
Find the five closest crossroads to the point with Latitude: 39 and Longitude: -123.

We first defined a POINT with the given coordinates. Then we used the coordinates in order to calculate the Euclidean distance between all the CROSSROAD nodes and the given point with coordinates (39,-123). We then sorted the results by Euclidean distance and kept the top 5 rows which contained the five closest nodes to the point with Latitude: 39 and Longitude: -123.

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/23.png)

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/24.png)

![alt text](https://github.com/evagian/California-road-network-NEO4J-CYPHER-graph-and-queries/blob/master/images/25.png)
