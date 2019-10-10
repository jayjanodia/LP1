'''source link: https://medium.com/@nicholas.w.swift/easy-a-star-pathfinding-7e6689c7f7b2'''


class Node():
	'''A node class for A* pathfinding'''
	
	def __init__(self, parent = None, position = None):
		self.parent = parent
		self.position = position
		self.f = 0
		self.g = 0
		self.h = 0
	
	#what have they done here
	def __eq__(self, other):
		return self.position == other.position
		
def astar(maze, start, end):
	'''Returns a list of tuples as a path from the given start to the given end in the given maze'''
	#Create start and end node
	start_node = Node(None, start)
	start_node.f = start_node.g = start_node.h = 0
	end_node = Node(None, end)
	end_node.f = end_node.g = end_node.h = 0
	
	#Initialize both open and closed list
	open_list = []
	closed_list = []
	
	#Add the start node
	open_list.append(start_node)
	
	#Loop until you find the end
	while len(open_list) > 0:
		
		#get the current node
		current_node = open_list[0]
		current_index = 0
		for index,item in enumerate(open_list):
			if item.f < current_node.f:
				current_node = item
				current_index = index
				
		#pop current_node off open_list, add to closed_list
		open_list.pop(current_index)
		closed_list.append(current_node)
		
		#found the goal
		if current_node == end_node:
			path = []
			current = current_node
			while current is not None:
				path.append(current.position)
				current = current.parent
			return path[::-1] #return reversed path
			
		#Generate children
		children = []
		#adjacent squares
		for new_position in [(0,-1), (0,1), (-1,0), (1,0), (-1,-1), (1,1), (-1,1), (1,-1)]:
		
			#get node position
			node_position = (current_node.position[0] + new_position[0], current_node.position[1] + new_position[1])
			
			#make sure within range
			if node_position[0] > (len(maze)-1) or node_position[0] < 0 or node_position[1] > len(maze[len(maze)-1]) or node_position[1]<0:
				continue
				
			#make sure walkable terrain
			if maze[node_position[0]][node_position[1]]!=0:
				continue
				
			#create new node
			new_node = Node(current_node, node_position)
			
			#Append
			children.append(new_node)
			
		#loop through children
		for child in children:
			#child is on the closed list
			for closed_child in closed_list:
				if child == closed_child:
					continue
					
			#Create the f,g,h values
			child.g = current_node.g + 1
			child.h = ((child.position[0] - end_node.position[0]) ** 2) + ((child.position[1] - end_node.position[1]) ** 2)
			child.f = child.g + child.h
			
			#child is already in the open list
			for open_node in open_list:
				if child == open_node and child.g > open_node.g:
					continue
					
			#add the child to the closed list
			open_list.append(child)
			
def main():

    maze = [[0, 0, 0, 0, 1, 0, 0, 0, 0, 0],[0, 0, 0, 0, 1, 0, 0, 0, 0, 0],[0, 0, 0, 0, 1, 0, 0, 0, 0, 0],[0, 0, 0, 0, 1, 0, 0, 0, 0, 0],[0, 0, 0, 0, 1, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],[0, 0, 0, 0, 1, 0, 0, 0, 0, 0],[0, 0, 0, 0, 1, 0, 0, 0, 0, 0],[0, 0, 0, 0, 1, 0, 0, 0, 0, 0],[0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
    try:
    	x,y = map(int, input('Enter starting coordinates: ').split(' '))
    	start = (x,y)
    	x,y = map(int, input('Enter end coordinates: ').split(' '))
    	end = (x,y)
    	path = astar(maze, start, end)
    	print(path)
    except Exception as e:
    	print(e)
    	#print('Please enter start value greater than 0,0 and end value smaller than 9,9')
	
if __name__ == '__main__':
	main()
