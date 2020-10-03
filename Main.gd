# Nome: Victor Domiciano Mendonca
# NUSP: 8641963

extends Node2D

const BLACK = Color(0, 0, 0)

var control_points = []
var drag_points = []
var is_dragging = false
var drag_point = null
var last_quadratic = false
var last_cubic = false
var quadratic = []
var cubic = []
var first_drag = false
var end_curve = []
var idx_first = 0
var show_drag = false

func _input(event):
	if event.is_action_pressed('ui_cancel'):
		control_points = []
		drag_points = []
		is_dragging = false
		drag_point = null
		last_quadratic = false
		last_cubic = false
		quadratic = []
		cubic = []
		first_drag = false
		end_curve = []
		idx_first = 0
		show_drag = false
	if event.is_action_pressed('ui_accept'):
		end_curve.remove(end_curve.size()-1)
		end_curve.append(true)
		show_drag = false
		first_drag = false
	if event.is_action_pressed('ui_del'):
		if last_quadratic:
			control_points.remove(control_points.size()-1)
			end_curve.remove(end_curve.size()-1)
			quadratic.remove(quadratic.size()-1)
			last_quadratic = false
			drag_points.remove(drag_points.size()-1)
			drag_points.remove(drag_points.size()-1)
		control_points.remove(control_points.size()-1)
		end_curve.remove(end_curve.size()-1)
		quadratic.remove(quadratic.size()-1)
		if control_points.size() > 0 and drag_points.size() > 0:
			if control_points[control_points.size()-1] == drag_points[drag_points.size()-1]:
				last_quadratic = true
				quadratic.remove(quadratic.size()-1)
				control_points.remove(control_points.size()-1)
				end_curve.remove(end_curve.size()-1)
	if event.is_action_pressed('left_button'):
		drag_point = get_viewport().get_mouse_position()
	if event is InputEventMouseMotion:
		if drag_point != null and drag_point != get_viewport().get_mouse_position():
			is_dragging = true
			show_drag = true
	if event.is_action_released('left_button'):
		var mouse_pos = get_viewport().get_mouse_position()
		if last_quadratic:
			control_points.append(drag_points[drag_points.size()-1])
			end_curve.append(false)
			quadratic.append(false)
		if last_cubic:
			cubic.append(false)
		if not (control_points.size() == 0 and first_drag):
			control_points.append(drag_point-(mouse_pos-drag_point))
			end_curve.append(false)
			quadratic.append(last_quadratic)
			cubic.append(last_cubic)
		if is_dragging:
			last_quadratic = true
			if last_quadratic:
				last_cubic = true
			drag_points.append(drag_point-(mouse_pos-drag_point))
			drag_points.append(mouse_pos)
			control_points.append(drag_point)
			end_curve.append(false)
			quadratic.append(false)
			cubic.append(false)
		else:
			last_quadratic = false
			last_cubic = false
		is_dragging = false
		drag_point = null
	update()

func _draw():
	var drag_size = drag_points.size()
	var mouse_pos = get_viewport().get_mouse_position()
	var control_size = control_points.size()
	for i in range(1, control_size):
		if i > end_curve.size() or (i <= end_curve.size() and not end_curve[i-1]):
			if not quadratic[i] and not control_points[i-1] in drag_points and not cubic[(i+1)%control_size]:
				draw_bezier(control_points[i-1], control_points[i], quadratic(control_points[i], i))
			if cubic[i] and not end_curve[i-2]:
				draw_bezier(control_points[i-2], control_points[i-1], control_points[i], quadratic(control_points[i], i))
	if control_size > 0 and end_curve.size() == 0 or (end_curve.size() > 0 and not end_curve[end_curve.size()-1]):
		if drag_size > 1 and not is_dragging and show_drag:
			if not first_drag or drag_size > 2:
				draw_circle(drag_points[drag_size-2], 3, BLACK)
				draw_circle(drag_points[drag_size-1], 3, BLACK)
				draw_line(drag_points[drag_size-2], drag_points[drag_size-1], BLACK)
			else:
				draw_circle(drag_points[drag_size-1], 3, BLACK)
				draw_line(control_points[idx_first], drag_points[drag_size-1], BLACK)
		if is_dragging:
			draw_circle(mouse_pos, 3, BLACK)
			draw_circle(drag_point-(mouse_pos-drag_point), 3, BLACK)
			draw_line(drag_point-(mouse_pos-drag_point), mouse_pos, BLACK)
			if last_quadratic:
				draw_bezier(control_points[control_size-1], drag_points[drag_size-1], drag_point-(mouse_pos-drag_point), drag_point)
			else:
				draw_bezier(control_points[control_size-1], drag_point-(mouse_pos-drag_point), drag_point)
		else:
			if last_quadratic:
				draw_bezier(control_points[control_size-1], drag_points[drag_size-1], mouse_pos)
			else:
				draw_line(control_points[control_size-1], mouse_pos, BLACK)
		return
	if is_dragging:
		draw_line(drag_point, mouse_pos, BLACK)
		first_drag = true
		if end_curve.size() > 0:
			idx_first = end_curve.size()+1
		else:
			idx_first = 0

func quadratic(p, i):
	if i < control_points.size()-1 and drag_points.has(p):
		return control_points[i+1]
	else:
		return null

func lerp_vector(p, q, weight):
	return Vector2(lerp(p.x, q.x, weight), lerp(p.y, q.y, weight))

func draw_bezier(p0, p1, p2=null, p3=null):
	if p2 == null:
		draw_line(p0, p1, BLACK)
		return
	if p3 == null:
		draw_quadratic_bezier(p0, p1, p2)
		return
	draw_cubic_bezier(p0, p1, p2, p3)

func draw_cubic_bezier(p0, p1, p2, p3):
	var weight = 0.0
	var r0 = p0
	var q0
	var q1
	var q2
	var r1
	while weight < 1.0:
		weight += 0.05
		q0 = lerp_vector(p0, p1, weight)
		q1 = lerp_vector(p1, p2, weight)
		q2 = lerp_vector(p2, p3, weight)
		r1 = lerp_vector(lerp_vector(q0, q1, weight), lerp_vector(q1, q2, weight), weight)
		draw_line(r0, r1, BLACK)
		r0 = r1

func draw_quadratic_bezier(p0, p1, p2):
	var weight = 0.0
	var q0 = p0
	var q1
	while weight < 1.0:
		weight += 0.05
		q1 = lerp_vector(lerp_vector(p0, p1, weight), lerp_vector(p1, p2, weight), weight)
		draw_line(q0, q1, BLACK)
		q0 = q1
