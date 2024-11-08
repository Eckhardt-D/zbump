const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const cwd = std.fs.cwd();

    var stdout = std.io.getStdOut();
    const writer = stdout.writer();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try writer.print("Usage: {s} <file_path>\n", .{args[0]});
        return;
    }

    const file_path: []const u8 = args[1];
    const is_absolute = file_path[0] == '/';

    const flags = std.fs.File.OpenFlags{
        .mode = .read_only,
    };

    var fd = (if (is_absolute) std.fs.openFileAbsolute(file_path, flags) else cwd.openFile(file_path, flags)) catch {
        try writer.print("Error opening file: {s}\n", .{file_path});
        return;
    };

    defer fd.close();

    // Read all the bytes and print them
    var buf: [4096]u8 = undefined;

    _ = fd.read(&buf) catch |err| {
        try writer.print("Error reading file: {any}\n", .{err});
        return;
    };

    if (!std.mem.eql(u8, buf[0..2], "BM")) {
        try writer.print("Not a BMP file\n", .{});
        return;
    }

    // Read the file size bytes into a single u32, little endian.
    const file_size: u32 = std.mem.readInt(u32, buf[2..6], .little);

    if (file_size == 0) {
        try writer.print("Empty File\n", .{});
        return;
    }

    // Read the offset to the pixel array bytes into a single u32, little endian.
    const pixel_array_offset: u32 = std.mem.readInt(u32, buf[10..14], .little);

    // Read the width and height bytes into a single u32, little endian.
    const width: u32 = std.mem.readInt(u32, buf[18..22], .little);
    const height: u32 = std.mem.readInt(u32, buf[22..26], .little);

    const padding = width % 4;
    const bytes_per_row = (width * 3) + padding;

    for (0..height) |y| {
        const row_start = (height - y - 1) * bytes_per_row;

        for (0..width) |x| {
            const offset = pixel_array_offset + row_start + (x * 3);

            if (offset + 2 >= buf.len) {
                try writer.print("Error: out of bounds", .{});
                std.process.exit(1);
            }

            const b = buf[offset];
            const g = buf[offset + 1];
            const r = buf[offset + 2];
            // Print twice to make the pixels square(ish)
            try writer.print("\x1b[48;2;{d};{d};{d}m \x1b[0m", .{ r, g, b });
            try writer.print("\x1b[48;2;{d};{d};{d}m \x1b[0m", .{ r, g, b });
        }

        try writer.print("\n", .{});
    }
}
