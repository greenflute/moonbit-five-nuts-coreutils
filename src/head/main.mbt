struct HeadOptions {
  mut file: String
  mut count: Int
  mut by_chars: Bool
}

fn print_usage() -> Unit {
  println("Usage:")
  println("  head [-c number|-n number] [file...]")
  println("")
  println("Options:")
  println("  -c number show last N characters")
  println("  -n number show last N lines")
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

fn parse_args(args: Array[String]) -> Result[HeadOptions, String] {
  if args.length() < 1 {
    return Err("No arguments provided")
  }

  let mut i = 0
  let options : HeadOptions = {
    file: "",
    count: 10, // 默认显示10行
    by_chars: false
  }
  let mut number_set = false

  // 正常模式解析
  while i < args.length() {
    match args[i] {
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

  Ok(options)
}

fn head!(file: String, by_chars: Bool, count: Int) -> Unit {
  let file_content = @fs.read_file_to_string!(path = file)
  
  if by_chars {
    // 按字符读取
    let content_length = file_content.length()
    let end_index = @math.minimum(count, content_length)
    let content_slice = file_content.substring(start = 0, end = end_index)
    
    println(content_slice)
  } else {
    // 按行读取
    let file_lines = file_content.split("\n").to_array()
    let end_index = @math.minimum(count, file_lines.length())
    let (content_slice, _) = file_lines.split_at(end_index)

    for line in content_slice {println(line)}
  }
}


// 使用示例
fn main {
  let args = @sys.get_cli_args()

  //test
  //for arg in args {println("DEBUG: arg: " + arg)}
  //let args = ["-n", "10", "example.txt"]
  //let args = ["-c", "10", "example.txt"]
  
  match parse_args(args) {
    Ok(options) => {
      // 这里使用解析后的选项执行tail操作
      // println("Parsed options:")
      // println("  file: " + options.file)
      // println("  count: " + options.count.to_string())
      // println("  by_chars: " + options.by_chars.to_string())

      let file_exists = @fs.is_file?(path = options.file) 
      match file_exists {
        Ok(true) => {
          let _ = head?(options.file, options.by_chars, options.count)
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