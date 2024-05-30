# Guard-And-Thief
Two-player hiding-in-plain-sight AI proof of concept.<br/><br/>

## AI Overview
The AI museum-goers in this proof-of-concept are designed to move in simple but realistic ways so that the art thief player can copy the AI's mannerisms to hide from the security guard player as one of the museum-goers. The GIF below shows the AI museum-goers wandering the museum.<br/><br/>

![GIF depicting AI museum-goers wandering around a museum](images/guardandthief_normal_operation.gif "Normal AI Operation")<br/><br/>

To allow for more realistic and varied movement for the AI, certain parts of the museum are designated as 'points of interest', like the areas near art pieces, exits, and high-traffic hallways. The AI will move to random points of interest to appear as if they are viewing art pieces, heading for exits, or waiting in hallways.<br/>
The screenshot below depicts the points of interest in this museum. The yellow rectangles are the areas for each point of interest, and the green dots are the pathfinding nodes that the AI uses to navigate to these areas.</br></br>

![Screenshot depicting the points and areas of interest in the museum](images/guardandthief_points_of_interest.png "Points of Interest")<br/><br/>

When the program is first started, a graph is generated that includes every open path between the pathfinding nodes of every point of interest.<br/>
The screenshot below depicts this graph.<br/><br/>

![Screenshot depicting the connections between points of interest](images/guardandthief_pathing_nodes.png "Pathing Nodes")<br/><br/>

TODO<br/><br/>

![GIF depicting a single AI museum-goer and its path](images/guardandthief_dynamic_pathing.gif "Dynamic AI Pathing")
