Monome Crow script that traverses an n-limit tonality diamond with graph search algorithms.

Collaboration with Ella Hoeppner.

Currently a WIP.

Meant to be used with the Monome Teletype. Call CROW.Q0 to return the note at the next node(a multiple of 1V, offset or scale as needed). CROW.C1 starts the traversal back over, the argument choosing which traversal algorithm is used. Currently 0 = breadth first, 1 = depth first.