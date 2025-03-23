/*
    This subpackage provides a set of basic pixel drawing primitives for the sake of convenience.
    Extending this collection for more advanced drawing is an exercise left to the user.
*/

package draw

import pixbuffer ".."
import "core:math"

Vec2 :: [2]int
Color :: pixbuffer.Color
Window :: pixbuffer.Window

pixel :: proc{
    pixel_xy,
    pixel_vec2,
}

pixel_xy :: proc(win: ^Window, x, y: int, color: Color) {
    if x >= 0 && x < win.width && y >= 0 && y < win.height {
        win.buffer[(win.width * y) + x] = transmute(u32)color
    }
}

pixel_vec2 :: proc(win: ^Window, pos: Vec2, color: Color) {
    pixel_xy(win, pos.x, pos.y, color)
}

rect :: proc {
    rect_xy,
    rect_vec2,
}

rect_xy :: proc(win: ^Window, x, y, w, h: int, color: Color) {
    for j in y..<y + h {
        for i in x..<x + w {
            pixel(win, i, j, color)
        }
    }
}

rect_vec2 :: proc(win: ^Window, pos, size: Vec2, color: Color) {
    rect_xy(win, pos.x, pos.y, size.x, size.y, color)
}

line :: proc{
    line_xyxy,
    line_vec2,
}

line_xyxy :: proc(win: ^Window, x0, y0, x1, y1: int, color: Color) {
    delta_x := x1 - x0
    delta_y := y1 - y0

    side_length := abs(delta_x) >= abs(delta_y) ? abs(delta_x) : abs(delta_y)

    x_inc := f32(delta_x) / f32(side_length)
    y_inc := f32(delta_y) / f32(side_length)

    current_x := f32(x0)
    current_y := f32(y0)

    for i in 0..<side_length {
        pixel(win, int(math.round(current_x)), int(math.round(current_y)), color)
        current_x += x_inc
        current_y += y_inc
    }
}

line_vec2 :: proc(win: ^Window, v0, v1: Vec2, color: Color) {
    line_xyxy(win, v0.x, v0.y, v1.x, v1.y, color)
}
