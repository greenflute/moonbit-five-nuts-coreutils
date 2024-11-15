struct TailOptions {
  mut file: String
  mut follow: Bool 
  mut reverse: Bool
  mut count: Int
  mut by_chars: Bool
}

fn print_usage() -> Unit {
  println("Usage:")
  println("  tail [-f] [-c number|-n number] [file]")
  println("  tail -r [-n number] [file]")
  println("")
  println("Options:")
  println("  -f        follow mode, output appended data as the file grows")
  println("  -c number show last N characters")
  println("  -n number show last N lines")
  println("  -r        reverse output")
}

fn parse_number(arg: String) -> Result[Int, String] {
  match @strconv.parse_int?(arg, base = 10) {
    Ok(n) => {
      if n <= 0 {
        return Err("Number must be non-negative")
      }else{
        return Ok(n)
      }
    }
    Err(_) => Err("Invalid number format")
  }

  
}

fn parse_args(args: Array[String]) -> Result[TailOptions, String] {
  if args.length() < 1 {
    return Err("No arguments provided")
  }

  let mut i = 0
  let options : TailOptions = {
    file: "",
    follow: false,
    reverse: false,
    count: 10, // 默认显示最后10行
    by_chars: false
  }
  let mut number_set = false

  // 检查是否是反向模式
  if args[0] == "-r" {
    options.reverse = true
    i = i + 1
    
    // 反向模式下不允许使用 -f 和 -c
    while i < args.length() {
      match args[i] {
        "-n" => {
          if number_set {
            return Err("Cannot specify number multiple times")
          }
          if i + 1 >= args.length() {
            return Err("Missing number after -n")
          }
          match parse_number(args[i + 1]) {
            Ok(n) => {
              if n <= 0 {
                return Err("Number must be non-negative")
              }else{
                options.count = n
                number_set = true
              }
            }
            Err(e) => return Err(e)
          }
          i = i + 2
        }
        //arg if arg.starts_with("-") => 
        //  return Err("Invalid option in reverse mode: " + arg)
        _ => {
          if options.file != "" {
            return Err("Multiple files specified")
          }
          options.file = args[i]
          i = i + 1
        }
      }
    }
  } else {
    // 正常模式解析
    while i < args.length() {
      match args[i] {
        "-f" => {
          options.follow = true
          i = i + 1
          return Err("Follow operation not supported yet")
        }
        "-c" => {
          if number_set {
            return Err("Cannot specify both -c and -n")
          }
          if i + 1 >= args.length() {
            return Err("Missing number after -c")
          }
          match parse_number(args[i + 1]) {
            Ok(n) => {
              if n <= 0 {
                return Err("Number must be non-negative")
              }else{
                options.count = n
                options.by_chars = true
                number_set = true
              }
            }
            Err(e) => return Err(e)
          }
          i = i + 2
        }
        "-n" => {
          if number_set {
            return Err("Cannot specify both -c and -n")
          }
          if i + 1 >= args.length() {
            return Err("Missing number after -n")
          }
          match parse_number(args[i + 1]) {
            Ok(n) => {
              if n <= 0 {
                return Err("Number must be non-negative")
              }else{
                options.count = n
                number_set = true
              }
            }
            Err(e) => return Err(e)
          }
          i = i + 2
        }
        //arg if arg.starts_with("-") =>
        //  return Err("Invalid option: " + arg)
        _ => {
          if options.file != "" {
            return Err("Multiple files specified")
          }
          options.file = args[i]
          i = i + 1
        }
      }
    }
  }

  Ok(options)
}

fn tail!(file: String, reverse: Bool, by_chars: Bool, count: Int, follow: Bool) -> Unit {
  let file_content = @fs.read_file_to_string!(path = file)
  
  if by_chars {
    // 按字符读取
    let content_length = file_content.length()
    let start_index = @math.maximum(0, content_length - count)
    let content_slice = file_content.substring(start = start_index, end = content_length)

    if reverse {
      // 反向模式
      let reversed_content = content_slice.rev()
      println(reversed_content)
    }else{
      println(content_slice)
    }
  } else {
    // 按行读取
    let file_lines = file_content.split("\n").to_array()
    let start_index = @math.maximum(0, file_lines.length() - count)
    let (_, content_slice) = file_lines.split_at(start_index)

    if reverse {
      // 反向模式
      let reversed_content = content_slice.rev()
      for line in reversed_content {println(line)}
    }else{
      for line in content_slice {println(line)}
    }
  }
  ignore(follow)
}


// 使用示例
fn main {
  let args = @sys.get_cli_args()

  //test
  //for arg in args {println("DEBUG: arg: " + arg)}
  //let args = ["-r", "-n", "30", "main.mbt"]
  //let args = ["-n", "10", "example.txt"]
  //let args = ["-c", "10", "example.txt"]
  //let args = ["-f", "-n", "10", "example.txt"]
  //let args = ["-r", "-n", "10", "example.txt"]

  match parse_args(args) {
    Ok(options) => {
      // 这里使用解析后的选项执行tail操作
      // println("Parsed options:")
      // println("  file: " + options.file)
      // println("  follow: " + options.follow.to_string())
      // println("  reverse: " + options.reverse.to_string())
      // println("  count: " + options.count.to_string())
      // println("  by_chars: " + options.by_chars.to_string())

      let file_exists = @fs.is_file?(path = options.file) 
      match file_exists {
        Ok(true) => {
          let _ = tail?(options.file, options.reverse, options.by_chars, options.count, options.follow)
        }
        _ => {
          println("Error: " + options.file + " does not exist")
          println("")
          print_usage()
        }
      }
    }
    Err(e) => {
      println("Error: " + e)
      println("")
      print_usage()
    }
  }
}