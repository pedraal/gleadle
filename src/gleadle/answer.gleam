import gleadle/parser
import gleam/dict.{type Dict}
import gleam/string

pub type Answer {
  Answer(string: String, letters: Dict(String, Int))
}

pub fn parse_answer(string) -> Answer {
  Answer(string, parser.letters_to_dict(string.split(string, on: "")))
}
