// 定义一个结构体 RmdirConfig，用于存储 rmdir 命令的配置选项
struct RmdirConfig {
  // 是否忽略删除非空目录时的失败
  ignore_fail_on_non_empty : Bool
  // 是否递归删除父目录
  parents : Bool
  // 是否启用详细输出
  verbose : Bool
  // 是否显示帮助信息
  help : Bool
  // 是否显示版本信息
  version : Bool
}
// 定义一个函数 `getopts`，用于解析命令行参数
fn getopts(args : Array[String]) -> Array[String] {
  // 创建一个队列来存储解析后的参数
  let list = @queue.new()
  // 遍历传入的参数
  for arg in args[2:] {
    // 如果参数以 "-" 开头且长度大于 2，并且不以 "--" 开头
    if arg.starts_with("-") && arg.length() > 2 && not(arg.starts_with("--")) {
      // 将参数中的每个字符拆分为单独的选项
      for i = 1; i < arg.length(); i = i + 1 {
        list.push("-" + arg[i].to_string())
      }
    } else {
      // 否则直接将参数加入队列
      list.push(arg)
    }
  }
  // 将队列转换为数组并返回
  return list.iter().collect()
}

// 定义一个函数 `strip_trailing_slashes`，用于去除路径末尾的斜杠
fn strip_trailing_slashes(dir : String) -> String {
  // 计算路径末尾的斜杠数量
  let trailing_slashes = dir.rev_iter().take_while(fn(c: Char) -> Bool { return c == '/'}).count()
  // 去除末尾的斜杠并返回结果
  return @string.concat(dir.iter().take(dir.length() - trailing_slashes).map(fn(c: Char) -> String { return c.to_string() }).collect(), separator="")
}

// 定义一个函数 `parent_dir`，用于获取路径的父目录
fn parent_dir(dir: String) -> Option[String] {
  // 去除路径末尾的斜杠
  let dir = strip_trailing_slashes(dir)
  // 将路径按斜杠分割成多个部分
  let parts = dir.split("/").collect()
  // 如果路径只有一个部分，返回 None
  if parts.length() == 1 {
    return None
  } else {
    // 否则返回父目录路径
    return Some(@string.concat(parts.iter().take(parts.length() - 1).collect(), separator="/"))
  }
}



fn rmdir(config : RmdirConfig, file : String) -> Unit {
  // check if file exists
  if not(@fs.path_exists(path=file)) {
    println("rmdir: failed to remove '" + file + "': No such file or directory")
    return
  }
  // check file is a directory
  match @fs.is_dir?(path=file) {
    Ok(flag) =>
      if not(flag) {
        println("rmdir: failed to remove '" + file + "': Not a directory")
        return
      }
    Err(_) => {
      println("rmdir: failed to remove '" + file + "': " + "unknown error")
      return
    }
  }
  // read files in directory
  let files_in_dir = match @fs.read_dir?(path=file) {
    Ok(l) => l
    Err(_) => {
      println(
        "rmdir: failed to read directory '" + file + "': " + "unknown error",
      )
      return
    }
  }

  // check if directory is empty
  if files_in_dir.length() > 0 {
    if not(config.ignore_fail_on_non_empty) {
      println("rmdir: failed to remove '" + file + "': Directory not empty")
      return
    }
  }

  // remove directory
  match @fs.remove_dir?(path=file) {
    Ok(_) => {
      if config.verbose {
        println("rmdir: removed directory '" + file + "'")
      }
      if config.parents {
        match parent_dir(file) {
          Some(parent) => rmdir(config, parent)
          None => return 
        }
      }
    }
    Err(_) =>
      println("rmdir: failed to remove '" + file + "': " + "unknown error")
  }
  return
}

fn main {
  let args = getopts(@sys.get_cli_args())
  let ignore_fail_on_non_empty_ref = @ref.new(false) // -l: 统计行数
  let parents_ref = @ref.new(false) // -w: 统计单词数
  let verbose_ref = @ref.new(false) // -m: 统计字符数
  let help_ref = @ref.new(false) // -c: 统计字节数
  let version_ref = @ref.new(false) // -L: 统计最长行长度
  let files : @queue.T[String] = @queue.new()
  let usage =
    #|Usage: rmdir [OPTION]... DIRECTORY...
    #|Remove the DIRECTORY(ies), if they are empty.
    #|  -I, --ignore-fail-on-non-empty
    #|                  ignore each failure that is solely because a directory       
    #|                  is non-empty
    #|  -p, --parents   remove DIRECTORY and its ancestors; e.g., 'rmdir -p a/b/c' is
    #|                  similar to 'rmdir a/b/c a/b a'
    #|  -V, --verbose   output a diagnostic for every directory processed
    #|  -h, --help      display this help and exit
    #|  -v, --version   output version information and exit
  @ArgParser.parse(
    [
      (
        "-I",
        "--ignore-fail-on-non-empty",
        Set(ignore_fail_on_non_empty_ref),
        "ignore each failure that is solely because a directory is non-empty",
      ),
      (
        "-p",
        "--parents",
        Set(parents_ref),
        "remove DIRECTORY and its ancestors; e.g., 'rmdir -p a/b/c' is similar to 'rmdir a/b/c a/b a'",
      ),
      (
        "-V",
        "--verbose",
        Set(verbose_ref),
        "output a diagnostic for every directory processed",
      ),
      ("-h", "--help", Set(help_ref), "display this help and exit"),
      (
        "-v",
        "--version",
        Set(version_ref),
        "output version information and exit",
      ),
    ],
    fn { file => files.push(file) },
    usage,
    args,
  )
  let config = {
    ignore_fail_on_non_empty: ignore_fail_on_non_empty_ref.val,
    parents: parents_ref.val,
    verbose: verbose_ref.val,
    help: help_ref.val,
    version: version_ref.val,
  }
  if config.help {
    println(usage)
    return
  }
  if config.version {
    println("rmdir 0.1.0")
    return
  }
  if files.is_empty() {
    println(usage)
    return
  }
  for file in files {
    rmdir(config, file)
  }
}

