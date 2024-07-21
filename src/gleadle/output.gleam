import gleam/io
import gleam/string

pub fn clear_last_line() {
  io.print("\u{1B}[A\u{1B}[2K")
}

pub fn padded_string(string: String, spaces pad: Int) {
  string.repeat(" ", pad) <> string
}
