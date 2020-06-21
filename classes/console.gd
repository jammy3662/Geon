extends Panel

onready var cmd: LineEdit = $cmd
onready var out_ln: Control = $output/lines

var MAX_STR_LENGTH = 61

func replace(obj: String, property: String, value):
	var node = get_node("*/"+obj)
	if node != null:
		if node.get(property) != null:
			print(node.get(property))
			newln("Initial value: "+String(node.get(property)))
		node.set(property, value)
	else: newln("Command failed: node could not be found.")

func commands():
	return [
	"clear",
	"setprop"
	]

# Use to set a single specified line to given text.
func setln(ind: int, txt: String):
	var nm: String = "ln" + String(ind)
	var ln = out_ln.get_node(nm) as Label
	ln.text = txt

# Clear all lines in console.
func clearconsole():
	for n in 18:
		var path = "ln" + String(n)
		var ln = out_ln.get_node(path)
		ln.text = ""
	newln("Cleared console. See log file for history.")

# Finds the index/number of the first open line in the console.		
func openln():
	for n in 18:
		var ln = out_ln.get_node("ln" + String(n))
		if ln.text.length() == 0:
			return n
		else:
			pass

# Add given set of lines to console, scrolling appropriately.
func append_lines(lines: Array):
	for line in lines:
		var ln = line as String
		#print(openln())
		if openln() == null:
			scroll_lines()
		if ln.length() > MAX_STR_LENGTH:
			var left = ln.left(MAX_STR_LENGTH)
			var right = ln.right(MAX_STR_LENGTH)
			setln(openln(), left)
			#print (lines.find(line))
			lines.insert(lines.find(line) + 1, right)
		else:
			setln(openln(), ln)
			

# Move each line up to the line above it, clearing the bottom line for new text.
# To scroll several times, use '_scroll_lines()'
func scroll_lines():
	for n in 18:
		if n < 17:
			var ln_0 = out_ln.get_node("ln" + String(n))
			var ln_1 = out_ln.get_node("ln" + String(n + 1))
			ln_0.text = ln_1.text
		else:
			var ln = out_ln.get_node("ln" + String(n))
			ln.text = ""

# Scroll up by the given amount of lines.		
func _scroll_lines(num: int):
	for n in num:
		self.scroll_lines()

func run_cmd(c: String, arg: Array):
	if c == "clear":
		if !arg.empty():
			if int(arg[0]) != null:
				var num = int(arg[0])
				num = clamp(num, 0, 18)
				_scroll_lines(num)
				newln("Cleared " + String(num) + " lines. See log for history.")
				return
		clearconsole()
	if c == "setprop":
		print (arg.size(), arg)
		if arg.size() > 2:
			var node = get_node("/root/lvl_scn/"+arg[0])
			if node != null:
				print(node.get(arg[1]))
				if node.get(arg[1]) != null:
					newln("Initial value: "+String(node.get(arg[1])))
					node.set(arg[1], arg[2])
				else:
					newln("Command failed: property '"+arg[1]+"' could not be found.")
					return
			else:
				newln("Command failed: node '"+arg[0]+"' could not be found.")
				return
			newln("Changed value '"+arg[1]+"' on object '"+arg[0]+"' to '"+arg[2]+"'")

func parse_cmd(c: String):
	var list = c.split(" ", false)
	var command = list[0]
	list.remove(0)
	var args = list
	for option in commands():
		if command == option:
			run_cmd(option, args)
			return
	newln("Command: '" + command + "' is invalid.")
		
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_ENTER and event.pressed:
			if cmd.text != "":
				#print("command: ", cmd.text)
				parse_cmd(cmd.text)
				cmd.text = ""

func newln(l: String):
	append_lines([l])

func _ready():
	#clearconsole()
	append_lines(["Console active.", "Geon Console.", "random"])
	pass
