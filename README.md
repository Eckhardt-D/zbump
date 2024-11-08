# Zbump - Zig BMP rendering in terminal

A for-fun project to render BMP images in terminal using Zig programming language.
Inspired by [0de5](https://www.0de5.net/stimuli/a-reintroduction-to-programming/essentials/binary-formats-through-bitmap-images) on [YouTube](https://www.youtube.com/watch?v=13E0il2zxBA).

## Clone

        git clone --depth=1 --single-branch https://github.com/Eckhardt-D/zbump.git

## Run

>[!NOTE]
>I tested this on WSL with Zig 0.13.0 :)

        cd zbump && zig build run -- fixtures/handcrafted.bmp

## Info

 - Accepts relative & absolute paths to BMP files.


## Build

        zig build -Doptimize=ReleaseSmall

Should now be in `zig-out/bin/zbump`



