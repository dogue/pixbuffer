package pixbuffer

import "core:fmt"
import sdl "vendor:sdl2"

Window :: struct {
    width: int,
    height: int,
    buffer: []u32,
    clear_color: Color,
    _handle: SDL_Handle,
}

Window_Options :: struct {
    title: string,
    pos: [2]int,
    width: int,
    height: int,
    flags: sdl.WindowFlags,
}

SDL_Handle :: struct {
    window: ^sdl.Window,
    renderer: ^sdl.Renderer,
    buffer_texture: ^sdl.Texture,
}

Error :: enum {
    None,
    Initialization_Failed,
    Window_Creation_Failed,
    Renderer_Creation_Failed,
    Texture_Creation_Failed,
}

Color :: distinct [4]u8

WHITE :: Color{255, 255, 225, 255}
BLACK :: Color{0, 0, 0, 255}
RED :: Color{255, 0, 0, 255}
GREEN :: Color{0, 255, 0, 255}
BLUE :: Color{0, 0, 255, 255}
YELLOW :: Color{255, 255, 0, 255}
MAGENTA :: Color{255, 0, 255, 255}
CYAN :: Color{0, 255, 255, 255}

CENTERED :: sdl.WINDOWPOS_CENTERED

init_window :: proc(opts: Window_Options, clear_color := BLACK, allocator := context.allocator) -> (window: ^Window, err: Error) {
    window = new(Window, allocator)

    if sdl.Init(sdl.INIT_VIDEO) != 0 {
        err = .Initialization_Failed
        return
    }

    display_mode: sdl.DisplayMode
    sdl.GetDisplayMode(0, 0, &display_mode)
    window.width = int(display_mode.w)
    window.height = int(display_mode.h)
    window.clear_color = clear_color

    window._handle.window = sdl.CreateWindow(
        fmt.ctprint(opts.title),
        i32(opts.pos.x),
        i32(opts.pos.y),
        i32(opts.width),
        i32(opts.height),
        opts.flags,
    )

    if window._handle.window == nil {
        err = .Window_Creation_Failed
        return
    }

    window._handle.renderer = sdl.CreateRenderer(window._handle.window, -1, {})

    if window._handle.renderer == nil {
        err = .Renderer_Creation_Failed
        return
    }

    window.buffer = make([]u32, (size_of(u32) * window.width * window.height), allocator)

    window._handle.buffer_texture = sdl.CreateTexture(
        window._handle.renderer,
        .ABGR8888,  // match Odin's [4]N ordering
        .STREAMING,
        i32(window.width),
        i32(window.height),
    )

    if window._handle.buffer_texture == nil {
        err = .Texture_Creation_Failed
    }

    return
}

destroy_window :: proc(win: ^Window, allocator := context.allocator) {
    sdl.DestroyTexture(win._handle.buffer_texture)
    sdl.DestroyRenderer(win._handle.renderer)
    sdl.DestroyWindow(win._handle.window)
    delete(win.buffer, allocator)
    free(win, allocator)
}

render :: proc(win: ^Window) {
    sdl.UpdateTexture(
        win._handle.buffer_texture,
        nil,
        raw_data(win.buffer),
        i32(size_of(u32) * win.width),
    )

    sdl.RenderCopy(
        win._handle.renderer,
        win._handle.buffer_texture,
        nil,
        nil,
    )

    clear(win, win.clear_color)
    sdl.RenderPresent(win._handle.renderer)
}

clear :: proc(win: ^Window, color: Color) {
    for &i in win.buffer {
        i = transmute(u32)color
    }
}

/*
    Re-export SDL2 event handling
*/

Event :: sdl.Event
Event_Type :: sdl.EventType
poll_event :: sdl.PollEvent
