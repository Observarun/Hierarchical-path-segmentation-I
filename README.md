# The Statistical Building Blocks of Animal Movement Simulations



## Overview

This repository shows a procedure to construct Statistical Movement Elements (StaMEs) from animal movement track. Movement data itself is in the form of a relocation time-sequence, given by a walk $`{W} = \{(t;x(t),y(t))|t=0,...,n^{time} \}.`$ The algorithm parses the normalised velocity (equivalent to normalised displacement or step length) and turning-angle time series (derived from the walk) into $z=1,\cdots,n^{\rm seg}$ segments (where $` n^{\rm seg}=\lfloor \frac{n^{\rm time}-1}{\mu} \rfloor `$) of size $\mu$ each. A clustering procedure is then applied on a hand-engineered representation comprising a set ($\cal S_{\mu}$) of the following statistical variables for each segment: mean velocity $V$, mean absolute turning angle $| \Delta \Theta |$, the associated standard deviations ${\rm SD}^{V}$ and ${\rm SD}^{| \Delta \Theta |}$, and finally, a normalized net displacement ($\Delta^{\rho}$). The last one is the Euclidean distance between the end points of each segment divided by a product of the number of points and mean step-length, and is required to pick up any possible circular motion type biases in movement.


## Hierarchical agglomerative clustering

Clustering is an unsupervised machine learning procedure which finds an optimum partition of a set of points with two or more variables into subsets (or clusters) of similar points. Here I've used hierarchical clustering approach, which results in a tree structure called dendrogram having a single cluster at the root, with leaf nodes representing data points in the set. Cluster analysis is performed on the segment level data (i.e., with $n_{\rm seg} = \lfloor \frac{t}{\mu} \rfloor +1$ points) using the variables in the se $\cal S_{\mu}$. Specifically, Iwant to find an optimal partition $\cal P(\cal S_{\mu}) = \{C_1, C_2, ..., C_k\},$ where $\cup_{i=1}^k C_i = \cal S_{\mu}$, and $C_i \cap C_j = \emptyset$ (hard clustering).

Hierarchical agglomerative algorithms implement bottom-up clustering methodology, which starts with each point of $\cal S$ in its own singleton cluster, followed by successive fusions of two clusters at a time, depending on similarity between them, leading to a specified number of clusters (or, alternatively, leading to one cluster followed by cutting the dendrogram at the desired number of clusters). These are deterministic, yet greedy, in the sense that the clusters are merged based entirely on the similarity measure, thereby yielding a local solution. Most of the similarity schemes are specified not in terms of an objective function to be optimized, but procedurally. I use Ward's minimum sum of square scheme, which performs a fusion of clusters while minimizing the intra-cluster variance. The distance metric to quantify dissimilarity is the Euclidean measure.


## Algorithm implemented

To perform clustering, I make use of $`\texttt{hclust}`$ function from $`\texttt{fastcluster}`$ $`\texttt{R}`$ package. It replaces the $`\texttt{stats}::\texttt{hclust}`$ function, which offers the most common implementation of Ward's hierarchical clustering in $`\texttt{R}`$. The conventional algorithm from $`\texttt{stats}`$ package takes as input the set of points $` \{ {\bf x}_z \}|_{z=1}^{n^{\rm seg}}=\big\{ V_z, ~{\rm SD}^V_z, ~ |\Delta \Theta|_z,~{\rm SD}^{|\Delta \Theta|}_z, \Delta^{\rho}_z \big\}\big|_{z=1}^{n^{\rm seg}} \in \mathbb{R}^{n^{\rm seg} \times 5} `$ (represented by $`{\mathcal S}_\mu `$) and a pair-wise dissimilarity matrix $` d(C_i,C_j)|_{i,j=1}^{n^{\rm seg}} `$ (to be computed in advance). Starting with $` n^{\rm seg} `$ clusters, it fuses multiple pairs of them in each of $` n^{\rm seg}-1 `$ steps while satisfying Ward's criterion and updates the dissimilarity matrix with the distance of each of the clusters still available to be merged with the newly created cluster. Accordingly, a series of partitions are produced, with the first one containing singleton clusters and the last one containing all $` n^{\rm seg} `$ points in one cluster. At each step, a set of clusters available to be merged (active clusters) is maintained, and each merger is tracked leading to a dendrogram. Concisely, the algorithm can be represented as shown next.![R:stats::hclust()](https://github.com/user-attachments/assets/2f235fd3-56e6-47ad-938e-e705b74d257a)
<br/>
The dendrogram thus produced can also be understood as a weighted graph, with leaf nodes representing data points, and each internal node representing the cluster of its descendent leaves. The dissimilarity between clusters is represented by edge weights. The Dendrogram can be cut at the required number of clusters.

This algorithm has a time complexity of $`{\mathcal O}({n^{\rm seg}}^3) `$ and requires $`\Omega({n^{\rm seg}}^2)`$ memory (on account of distance matrix computation and storage), making it unsuitable for our segment-level data set with $`\sim~10^5 `$ points. Further, it is also difficult to distribute over multiple threads because the complete dissimilarity matrix along with active clusters and current state of dendrogram is required by all the processes. To get around these difficulties, I make two modifications to this workflow. First, I make use of $`\texttt{parDist}`$ function of $`\texttt{parallelDist}`$ package, which permits parallel computations of pair-wise dissimilarities. It offers the same interface as that of $`\texttt{stats::dist}`$ $`\texttt{R}`$ function. Second, I use an improved algorithm for hierarchical agglomerative clustering from $`\texttt{fastcluster}`$ package, as mentioned above. The algorithm performs hierarchical clustering with Ward's scheme faster by accomplishing the search for the best cluster to merge with any cluster in the most efficient way. For the clustering procedure, I choose to not perform dimensional reduction and use all $`5`$ variables in $`{\mathcal S}_{\mu}`$. This ensures enhanced interpretation of results.


## Description of scripts

* 01_step-length_turning-angle_barn-owl.R: Computation of step length (or speed) and turning angle time series starting from the multi-DAR relocation time-series data for a barn owl individual obtained using the ATLAS reverse GPS system in north-eastern Israel.
* 01_step-length_turning-angle_ANIMOVER1.R: Computation of step length and turning angle time series starting from 2-mode simulated multi-DAR relocation data generated from Numerus ANIMOVER_1.
* 02_segmentation.R: Parsing of multi-DAR speed and turning angle series into segments of $`\mu`$ points each to construct a representation using a set of statistics for each segment for barn owl and ANIMOV data.
* 03_clustering_visualisation.R: Clustering analysis on the representation previously obtained to perform StaME extraction along with visualisation of results for barn owl and ANIMOV data.

## Results

![Numerus ANIMOVER_1](https://github.com/user-attachments/assets/19a819ea-a7ea-4ad6-adf1-db16d124cbb3)
<br/>
*StaMEs obtained from 10-point and 30-point segmentation of the simulation data.*

![GG412(5+6)9](https://github.com/user-attachments/assets/09c13b8b-13af-4b65-a921-0d95f621ecd9)
<br/>
*StaMEs obtained by clustering segments from the tracks of two different barn owls.*
