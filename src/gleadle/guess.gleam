import colored
import gleadle/answer.{type Answer, Answer} as answer_mod
import gleadle/output
import gleadle/parser
import gleam/dict.{type Dict}
import gleam/erlang
import gleam/io
import gleam/list
import gleam/result
import gleam/string

pub const prompt = "Your guess: "

pub type LetterState {
  Wrong
  Misplaced
  Correct
}

pub type LetterGuess {
  LetterGuess(letter: String, state: LetterState)
}

pub type ProcessedGuess {
  ProcessedGuess(letters: List(LetterGuess))
}

pub type GuessResult {
  GuessResult(raw: String, colored: String)
}

pub fn start(word: String, max_attempts: Int) {
  let parsed_answer = answer_mod.parse_answer(word)
  let obfuscated_answer = parser.obfuscate_string(parsed_answer.string)
  check_and_ask(
    GuessResult(raw: obfuscated_answer, colored: obfuscated_answer),
    parsed_answer,
    0,
    max_attempts,
  )
}

pub fn check_and_ask(
  guess: GuessResult,
  answer: Answer,
  attempt: Int,
  max_attempts: Int,
) {
  case attempt > 0 {
    True -> output.clear_last_line()
    _ -> Nil
  }

  let print_spaces = string.length(prompt)

  print(guess, spaces: print_spaces)

  let is_correct = guess.raw == answer.string
  let is_over = attempt >= max_attempts

  case is_correct, is_over {
    True, _ -> io.print(output.padded_string("You win !", spaces: print_spaces))
    _, True ->
      io.print(output.padded_string("Game over :(", spaces: print_spaces))
    _, _ -> {
      erlang.get_line(prompt)
      |> result.unwrap(guess.raw)
      |> string.trim
      |> process(answer, ProcessedGuess([]))
      |> refine(answer, GuessResult("", ""))
      |> check_and_ask(answer, attempt + 1, max_attempts)
    }
  }
}

fn process(guess: String, answer: Answer, processed: ProcessedGuess) {
  let guess_list = string.split(guess, on: "")
  let expected_list = string.split(answer.string, on: "")
  case guess_list, expected_list {
    [guess_letter, ..guess_rest], [expected_letter, ..expected_rest] -> {
      let letter_guess =
        check_char(
          guess_letter,
          expected_letter,
          answer.letters |> dict.to_list |> list.map(fn(v) { v.0 }),
        )
      process(
        string.join(guess_rest, with: ""),
        Answer(..answer, string: string.join(expected_rest, with: "")),
        ProcessedGuess(list.concat([processed.letters, [letter_guess]])),
      )
    }
    _, _ -> processed
  }
}

fn refine(guess: ProcessedGuess, answer: Answer, result: GuessResult) {
  list.filter(guess.letters, fn(lg) { lg.state == Correct })
  |> list.map(fn(lg) { lg.letter })
  |> parser.letters_to_dict()
  |> refine_loop(guess, answer, result)
}

fn refine_loop(
  correct_dict: Dict(String, Int),
  guess: ProcessedGuess,
  answer: Answer,
  result: GuessResult,
) {
  let return = fn(
    letter: String,
    letters: List(LetterGuess),
    color_fn: fn(String) -> String,
  ) {
    refine_loop(
      correct_dict,
      ProcessedGuess(letters),
      answer,
      GuessResult(result.raw <> letter, result.colored <> color_fn(letter)),
    )
  }
  case guess.letters {
    [LetterGuess(letter, Misplaced), ..letters] -> {
      let correct_count =
        dict.get(correct_dict, letter)
        |> result.unwrap(0)
      let expected_count =
        dict.get(answer.letters, letter)
        |> result.unwrap(0)

      case correct_count == expected_count {
        True -> return(letter, letters, colored.red)
        _ -> return(letter, letters, colored.yellow)
      }
    }
    [LetterGuess(letter, Correct), ..letters] -> {
      return(letter, letters, colored.green)
    }
    [LetterGuess(letter, Wrong), ..letters] -> {
      return(letter, letters, colored.red)
    }
    _ -> result
  }
}

fn check_char(current: String, expected: String, possibilities) -> LetterGuess {
  let is_exact = current == expected
  let is_possible = list.contains(possibilities, current)
  let state = case is_exact, is_possible {
    True, _ -> Correct
    _, True -> Misplaced
    _, _ -> Wrong
  }

  LetterGuess(current, state)
}

pub fn print(guess: GuessResult, spaces pad: Int) {
  io.println(output.padded_string(guess.colored, spaces: pad))
}
