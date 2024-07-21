import argv
import gleadle/guess
import gleadle/output
import gleadle/words
import gleam/io
import gleam/list
import gleam/result
import gleam/string

const max_attempts = 4

pub fn main() {
  let args = argv.load()
  let locale =
    list.first(args.arguments)
    |> result.unwrap("en")
  let word = words.get_word_for(locale)
  io.println("")
  io.println(output.padded_string(
    "Guess the word !",
    spaces: string.length(guess.prompt),
  ))
  guess.start(word, max_attempts)
}
