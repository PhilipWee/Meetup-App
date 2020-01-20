#Closest nodes are from 566720733 and the restaurants are [2598017481, 5097279855, 1110900252, 5681549971, 4740582463]

#For each closest restuarant, we need to djistra out till we have touched the edge of each of the starting node circles
#circle array sets for a single graph only, split the graph before running the function
def rest_to_each_circle(graph,rest_nodes,circle_array_sets,weight=get_edge_weight,cutoff=None,paths=None,pred=None):
    G_succ = graph._succ if graph.is_directed() else graph._adj
    push = heappush
    pop = heappop
    dists = [{} for x in rest_nodes]
    seens = [{} for x in rest_nodes]
    dones = [False for x in rest_nodes]
    checked = [[] for x in rest_nodes]
    for x in checked:
        for item in circle_array_sets:
            x.append(False)
#    print(checked)
    c = count()
    fringes = [[] for x in sources]
    for rest_node,seen,fringe in zip(rest_nodes,seens,fringes):
        if rest_node not in graph:
            raise nx.NodeNotFound("Restaurant Node {} not in G".format(rest_node))
        seen[rest_node] = 0
        push(fringe,(0,next(c),rest_node))
    while True:
        for i,(fringe,dist,seen) in enumerate(zip(fringes,dists,seens)):
            if dones[i]:
                continue
            (d, _, v) = pop(fringe)
            if v in dist:
                continue #already searched this node
            dist[v] = d
#            other_dists = dists[:i] + dists[i+1:]
#            found = True
#            for other_dist in other_dists:
#                if v not in other_dist.keys():
#                    found = False
#                    continue
#            if found:
#                return v
#            if v in circle_array_set.keys():
#                #This needs to be replaced so that all five are completed
#                print(v,i)
#                dones[i] = True
#                if False not in dones:
#                    return v
            for iterator,circle_array_set in enumerate(circle_array_sets):
                if v in circle_array_set.keys():
                    checked[i][iterator] = True
#                    print(checked)
            if False not in checked[i]:
#                print(checked)
                return v
                    
            for u,e in G_succ[v].items():
                cost = weight(v,u,e)
                if cost is None:
                    continue
                vu_dist = dist[v] + cost
                if cutoff is not None:
                    if vu_dist > cutoff:
                        continue
                if u in dist:
                    if vu_dist < dist[u]:
                        raise ValueError('Contradictory paths found, negative weights?')
                elif u not in seen or vu_dist < seen[u]:
                    seen[u] = vu_dist
                    push(fringe, (vu_dist, next(c), u))
                    if paths is not None:
                        #Need to get the path somehow
                        paths[u] = paths[v] + [u]
                    if pred is not None:
                        pred[u] = [v]
                elif vu_dist == seen[u]:
                    if pred is not None:
                        pred[u].append(v)

#33981077
#Sources are [778256788,1118372124,1239287126]
#Closest nodes are from 566720733 and the restaurants are [2598017481, 5097279855, 1110900252, 5681549971, 4740582463]
start_time = time.time()
rest_to_each_circle(G_public,[2598017481],[original_seens[778256788],original_seens[1118372124],original_seens[1239287126]])
time_elapsed = time.time() - start_time
print(time_elapsed)

start_time = time.time()
list(nx.edge_dfs(G_public))
time_elapsed = time.time() - start_time
print(time_elapsed)

# -*- coding: utf-8 -*-
"""
Created on Tue Jan 14 13:31:42 2020

@author: Philip
"""

def _dijkstra_multisource(G, sources, weight, pred=None, paths=None,
                          cutoff=None, target=None):
    """Uses Dijkstra's algorithm to find shortest weighted paths

    Parameters
    ----------
    G : NetworkX graph

    sources : non-empty iterable of nodes
        Starting nodes for paths. If this is just an iterable containing
        a single node, then all paths computed by this function will
        start from that node. If there are two or more nodes in this
        iterable, the computed paths may begin from any one of the start
        nodes.

    weight: function
        Function with (u, v, data) input that returns that edges weight

    pred: dict of lists, optional(default=None)
        dict to store a list of predecessors keyed by that node
        If None, predecessors are not stored.

    paths: dict, optional (default=None)
        dict to store the path list from source to each node, keyed by node.
        If None, paths are not stored.

    target : node label, optional
        Ending node for path. Search is halted when target is found.

    cutoff : integer or float, optional
        Depth to stop the search. Only return paths with length <= cutoff.

    Returns
    -------
    distance : dictionary
        A mapping from node to shortest distance to that node from one
        of the source nodes.

    Raises
    ------
    NodeNotFound
        If any of `sources` is not in `G`.

    Notes
    -----
    The optional predecessor and path dictionaries can be accessed by
    the caller through the original pred and paths objects passed
    as arguments. No need to explicitly return pred or paths.

    """
    G_succ = G._succ if G.is_directed() else G._adj

    push = heappush
    pop = heappop
    dist = {}  # dictionary of final distances
    seen = {}
    # fringe is heapq with 3-tuples (distance,c,node)
    # use the count c to avoid comparing nodes (may not be able to)
    c = count()
    fringe = []
    for source in sources:
        if source not in G:
            raise nx.NodeNotFound("Source {} not in G".format(source))
        seen[source] = 0
        push(fringe, (0, next(c), source))
    while fringe:
        (d, _, v) = pop(fringe)
        if v in dist:
            continue  # already searched this node.
        dist[v] = d
        if v == target:
            break
        for u, e in G_succ[v].items():
            cost = weight(v, u, e)
            if cost is None:
                continue
            vu_dist = dist[v] + cost
            if cutoff is not None:
                if vu_dist > cutoff:
                    continue
            if u in dist:
                if vu_dist < dist[u]:
                    raise ValueError('Contradictory paths found:',
                                     'negative weights?')
            elif u not in seen or vu_dist < seen[u]:
                seen[u] = vu_dist
                push(fringe, (vu_dist, next(c), u))
                if paths is not None:
                    paths[u] = paths[v] + [u]
                if pred is not None:
                    pred[u] = [v]
            elif vu_dist == seen[u]:
                if pred is not None:
                    pred[u].append(v)

    # The optional predecessor and path dictionaries can be accessed
    # by the caller via the pred and paths objects passed as arguments.
    return dist

def get_edge_weight(v,u,e):
    return e['cost']

start_time = time.time()
_dijkstra_multisource(G_public,[778256788],get_edge_weight)
_dijkstra_multisource(G_public,[1118372124],get_edge_weight)
_dijkstra_multisource(G_public,[1239287126],get_edge_weight)
time_elapsed = time.time() - start_time
print(time_elapsed)
