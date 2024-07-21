import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn letters_to_dict(letters: List(String)) -> Dict(String, Int) {
  list.map(letters, fn(letter) { #(letter, 1) })
  |> list.fold(dict.new(), fn(acc, item) {
    let increment = fn(l) {
      case l {
        Some(i) -> i + 1
        None -> 1
      }
    }

    dict.upsert(acc, item.0, increment)
  })
}

pub fn obfuscate_string(str: String) -> String {
  string.split(str, on: "")
  |> list.index_map(fn(l, i) {
    case i {
      0 -> l
      _ -> "-"
    }
  })
  |> string.join(with: "")
}
