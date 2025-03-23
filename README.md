# Pixbuffer

A basic CPU-rendered pixel buffer for Odin, using SDL2. Inspired by Rust's [`minifb`](https://github.com/emoon/rust_minifb) crate.

## Features

- Customizable window creationg using standard SDL2 flags
- Convenient wrappers around initialization and rendering
- Full exposure of the underlying data, meaning all of SDL2 is still available to you
- A small set of simple drawing primitives (pixel, rect, line) in the `pixbuffer/draw` package

## Example

```odin
import pb "pixbuffer"
import "pixbuffer/draw"
import "core:fmt"

main :: proc() {
    opts := pb.Window_Options {
        title = "Pixbuffer",
        pos = {pb.CENTERED, pb.CENTERED},
        width = 640,
        height = 480,
    }

    window, err := pb.init_window(opts)
    if err != .None {
        fmt.eprintfln("error initializing: %s", err)
        return
    }
    defer pb.destroy_window(win)

    should_close := false
    for !should_close {
        event: pb.Event         // this is an SDL2 `Event`, re-exported
        pb.poll_event(&event)   // this is `sdl2.PollEvent`, re-exported

        #partial switch event.type {
        case .QUIT:
            should_close = true

        case .KEYDOWN:
            if event.key.keysym.sym == .ESCAPE {
                should_close = true
            }
        }

        draw.rect(win, 20, 20, 100, 100, pb.RED)
        pb.render(win)
    }
}
```
