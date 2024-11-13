struct Stats {
  lines : Int?
  words : Int?
  characters : Int?
  bytes : Int?
  max_line_length : Int?
}


fn Stats::to_strings(self : Stats) -> Array[String] {
  let list = [
    self.lines,
    self.words,
    self.characters,
    self.bytes,
    self.max_line_length,
  ]
  list
    .iter()
    .map(
      fn(x) {
        match x {
          Some(n) => n.to_string()
          None => ""
        }
      },
    )
    .collect()
}


fn Stats::to_string(self : Stats) -> String {
  @string.concat(self.to_strings().filter(fn(x) { x.length() > 0 }), separator=" ")
}
fn print_stats(list : @queue.T[(Stats, String)], total_stats : Stats) -> Unit {
  if (list.is_empty()) {
    println("wc: print stats error: list is empty")
    @sys.exit(-1)
  }
  // let max_file_length = list.iter().map(fn(pair) {pair.1.length()}).fold(fn(a: Int, b: Int) {if a > b {a} else {b}}, init=0)
  let fix_length = [match total_stats.lines {
    None => 0
    Some(x) => x.to_string().length()
  }, match total_stats.words {
    None => 0
    Some(x) => x.to_string().length()
  }, match total_stats.characters {
    None => 0
    Some(x) => x.to_string().length()
  }, match total_stats.bytes {
    None => 0
    Some(x) => x.to_string().length()
  }, match total_stats.max_line_length {
    None => 0
    Some(x) => x.to_string().length()
  }]
  list.each(fn (item: (Stats, String)) {
    let (stats, file) = item
    let strings = stats.to_strings()
    let output = @queue.new()
    for i = 0; i < fix_length.length(); i = i + 1 {
      if fix_length[i] > 0 && strings[i].length() > 0 {
        let whitespace = fix_length[i] + 1 - strings[i].length() 
        for j = 0; j < whitespace; j = j + 1 {
          output.push(" ")
        }
        output.push(strings[i])
      }
    }
    output.push(" ")
    output.push(file)
    println(@string.concat(output.iter().collect(), separator=""))
  })
}

fn Stats::op_add(self : Stats, other : Stats) -> Stats {
  fn option_add(x : Int?, y : Int?) -> Int? {
    match (x, y) {
      (None, _) => y
      (_, None) => x
      (Some(a), Some(b)) => Some(a + b)
    }
  }

  fn option_max(x : Int?, y : Int?) -> Int? {
    match (x, y) {
      (None, _) => y
      (_, None) => x
      (Some(a), Some(b)) => Some(if a > b { a } else { b })
    }
  }

  {
    lines: option_add(self.lines, other.lines),
    words: option_add(self.words, other.words),
    characters: option_add(self.characters, other.characters),
    bytes: option_add(self.bytes, other.bytes),
    max_line_length: option_max(self.max_line_length, other.max_line_length),
  }
}

fn word_count(
  content : String,
  file_bytes: Bytes?,
  ~line : Bool,
  ~word : Bool,
  ~char : Bool,
  ~byte : Bool,
  ~max_line_length : Bool
) -> Stats {
  let lines = if line { Some(content.split("\n").count()) } else { None }
  let words = if word { Some(content.replace_all(old="\n", new=" ").split(" ").filter(fn(s) {s.length() > 0}).count()) } else { None }
  let characters = if char { Some(content.length()) } else { None }
  let bytes = if byte { Some(file_bytes.unwrap().length()) } else { None } 

  let max_line_length = if max_line_length {
    Some(
      content
      .split("\n")
      .map(fn(line) { line.length() })
      .fold(fn(a : Int, b : Int) { if a > b { a } else { b } }, init=0),
    )
  } else {
    None
  }
  { lines, words, characters, bytes, max_line_length }
}

fn main {
  let args = @env.get_args()
  let line_ref = @ref.new(false) // -l: 统计行数
  let word_ref = @ref.new(false) // -w: 统计单词数
  let char_ref = @ref.new(false) // -m: 统计字符数
  let byte_ref = @ref.new(false) // -c: 统计字节数
  let max_line_length_ref = @ref.new(false) // -L: 统计最长行长度
  let help_flag = @ref.new(false) // --help: 显示帮助
  let version_flag = @ref.new(false) // --version: 显示版本信息
  let files : @queue.T[String] = @queue.new()
  let mut returncode = 0
  let usage =
    #| wc - Print newline, word, and byte counts for each FILE, and a total line if
    #| more than one FILE is specified.  A word is a non-zero-length sequence of
    #| characters delimited by white space.
    #| usage: 
    #|      wc [OPTION]... [FILE]...
    #| options:
    #|      -c, --bytes            print the byte counts
    #|      -m, --chars            print the character counts
    #|      -l, --lines            print the newline counts
    #|      -L, --max-line-length  print the maximum display width
    #|      -w, --words            print the word counts
    #|      -h, --help             display this help and exit
    #|      -v, --version          output version information and exit
    #|
  @ArgParser.parse(
    [
      ("-l", "--lines", Set(line_ref), "print the newline counts"),
      ("-w", "--words", Set(word_ref), "print the word counts"),
      ("-m", "--chars", Set(char_ref), "print the character counts"),
      ("-c", "--bytes", Set(byte_ref), "print the byte counts"),
      (
        "-L",
        "--max-line-length",
        Set(max_line_length_ref),
        "print the maximum display width",
      ),
      ("-h", "--help", Set(help_flag), "display this help and exit"),
      (
        "-v",
        "--version",
        Set(version_flag),
        "output version information and exit",
      ),
    ],
    fn { file => files.push(file) },
    usage,
    args,
  )
  let (char, max_line_length) = (char_ref.val, max_line_length_ref.val)
  let mut line = line_ref.val
  let mut word = word_ref.val
  let mut byte = byte_ref.val
  if help_flag.val {
    println(usage)
    return
  }
  if version_flag.val {
    println("wc 0.1.0")
    return
  }
  if not(line || word || byte || char || max_line_length) {
    line = true
    word = true
    byte = true
  }

  //
  if files.is_empty() {
    let lines : @queue.T[String] = @queue.new()
    loop @io.read_line_from_stdin() {
      None => break
      Some(line) =>
        continue {
            lines.push(line)
            @io.read_line_from_stdin()
          }
    }
    let content = @string.concat(lines.iter().collect(), separator="")
    let stats = word_count(
      content,
      if byte {Some(content.to_bytes())} else {None},
      ~line,
      ~word,
      ~char,
      ~byte,
      ~max_line_length,
    )
    println("  \{stats.to_string()}")
  } else {
    let mut total_stats = {
      lines: if line {
        Some(0)
      } else {
        None
      },
      words: if word {
        Some(0)
      } else {
        None
      },
      bytes: if byte {
        Some(0)
      } else {
        None
      },
      characters: if char {
        Some(0)
      } else {
        None
      },
      max_line_length: if max_line_length {
        Some(0)
      } else {
        None
      },
    }
    let list = @queue.new()
    files
    .iter()
    .each(
      fn(file) {
        if not(@fs.path_exists(path=file)) {
          println("wc: \{file}: No such file or directory")
          returncode = 1
          return
        }
        let content = match @fs.read_file_to_string?(path=file) {
          Ok(s) => s
          Err(_) => {
            println("wc: \{file}: meet a error when read file")
            returncode = 1
            return
          }
        }

        let bytes = if byte {
           match @fs.read_file_to_bytes?(path=file) {
            Ok(s) => Some(s)
            Err(_) => {
              println("wc: \{file}: meet a error when read file")
              returncode = 1
              return
            }
          }
        } else {
          None
        }
        let stats = word_count(
          content,
          bytes,
          ~line,
          ~word,
          ~char,
          ~byte,
          ~max_line_length,
        )
        total_stats += stats
        list.push((stats, file))
      },
    )
    if list.length() == 1 { // 不需要打印total
      let (stat, file) = list.pop().unwrap()
      println(" \{stat.to_string()} \{file}")
    } else {
      list.push((total_stats, "total"))
      print_stats(list, total_stats)
    }
    
  }
  @sys.exit(returncode)
  println("args: \{args}")
}
