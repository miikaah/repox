const c = @cImport({
    @cInclude("stdlib.h");
});

pub fn main() !void {
    _ = c.system("git status");
}
