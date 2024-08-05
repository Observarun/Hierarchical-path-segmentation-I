# The Statistical Building Blocks of Animal Movement Simulations


This repository shows a procedure to construct Statistical Movement Elements (StaMEs) from animal movement track. Movement data itself is in the form of a relocation time-sequence, given by a walk $`{W} = \{(t;x(t),y(t))|t=0,...,n^{time} \}.`$ The algorithm parses the normalised velocity (equivalent to normalised displacement or step length) and turning-angle time series (derived from the walk) into $z=1,\cdots,n^{\rm seg}$ segments (where $` n^{\rm seg}=\lfloor \frac{n^{\rm time}-1}{\mu} \rfloor `$) of size $\mu$ each. A clustering procedure is then applied on a hand-engineered representation comprising a set ($\cal S_{\mu}$) of the following statistical variables for each segment: mean velocity $V$, mean absolute turning angle $| \Delta \Theta |$, the associated standard deviations ${\rm SD}^{V}$ and ${\rm SD}^{| \Delta \Theta |}$, and finally, a normalized net displacement ($\Delta^{\rho}$). The last one is the Euclidean distance between the end points of each segment divided by a product of the number of points and mean step-length, and is required to pick up any possible circular motion type biases in movement.

Clustering is an unsupervised machine learning procedure which finds an optimum partition of a set of points with two or more variables into subsets (or clusters) of similar points. Here I've used hierarchical clustering approach, which results in a tree structure called dendrogram having a single cluster at the root, with leaf nodes representing data points in the set. Cluster analysis is performed on the segment level data (i.e., with $n_{\rm seg} = \lfloor \frac{t}{\mu} \rfloor +1$ points) using the variables in the se $\cal S_{\mu}$. Specifically, we want to find an optimal partition $\cal P(\cal S_{\mu}) = \{C_1, C_2, ..., C_k\},$ where $\cup_{i=1}^k C_i = \cal S_{\mu}$, and $C_i \cap C_j = \emptyset$ (hard clustering).

Hierarchical agglomerative algorithms implement bottom-up clustering methodology, which starts with each point of $\cal S$ in its own singleton cluster, followed by successive fusions of two clusters at a time, depending on similarity between them, leading to a specified number of clusters (or, alternatively, leading to one cluster followed by cutting the dendrogram at the desired number of clusters). These are deterministic, yet greedy, in the sense that the clusters are merged based entirely on the similarity measure, thereby yielding a local solution. Most of the similarity schemes are specified not in terms of an objective function to be optimized, but procedurally. I use Ward's minimum sum of square scheme, which performs a fusion of clusters while minimizing the intra-cluster variance. The distance metric to quantify dissimilarity is the Euclidean measure.

## Description of scripts

* 01_step-length_turning-angle_barn-owl.R: Computation of step length (or speed) and turning angle time series starting from the multi-DAR relocation time-series data for a barn owl individual obtained using the ATLAS reverse GPS system in north-eastern Israel.
* 01_step-length_turning-angle_ANIMOVER1.R: Computation of step length and turning angle time series starting from 2-mode simulated multi-DAR relocation data generated from Numerus ANIMOVER_1.
* 02_segmentation.R: Parsing of multi-DAR speed and turning angle series into segments of $`\mu`$ points each to construct a representation using a set of statistics for each segment for barn owl and ANIMOV data.
* 03_clustering_visualisation.R: Clustering analysis on the representation previously obtained to perform StaME extraction along with visualisation of results for barn owl and ANIMOV data.

## Results

![ClustersOwl](https://github.com/Observarun/Hierarchical-path-segmentation-I/issues/1#issue-2448444689)
*StaMEs obtained by clustering segments from the tracks of two different barn owls.*

![ClustersSim](https://github.com/Observarun/Hierarchical-path-segmentation-I/issues/2#issue-2448445665)
*Clustering results from 10-point and 30-point segmentation of the simulation data.*
