import gleadle/words/en
import gleadle/words/fr
import gleam/list
import gleam/result

pub fn get_word_for(locale: String) {
  case locale {
    "fr" -> get_word_from(fr.words, fr.default_word)
    _ -> get_word_from(en.words, en.default_word)
  }
}

fn get_word_from(words: List(String), default: String) {
  list.shuffle(words)
  |> list.first
  |> result.unwrap(default)
}
