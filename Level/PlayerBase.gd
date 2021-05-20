extends Spatial
class_name PlayerBase

func open_doors():
	for child in self.get_children():
		if child is Door:
			child.open()

func close_doors():
	for child in self.get_children():
		if child is Door:
			child.close()
