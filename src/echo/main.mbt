fn parse_special_char(s: String) -> String {
  let s_array = s.to_array()

  let mut result = ""
  let mut i = 0
  while i < s.length() {
    if s[i] == '\\' {
      if i + 1 >= s.length() {
        result = result + "\\"
        break
      }
      match s[i + 1] {
        'a' => {
          result = result + "\u0007"  // Bell/Alert (BEL)
          i = i + 2
        }
        'b' => {
          result = result + "\u0008"  // Backspace (BS)
          i = i + 2
        }
        'c' => {
          // Suppress everything after \c
          break
        }
        'f' => {
          result = result + "\u000C"  // Form feed (FF)
          i = i + 2
        }
        'n' => {
          result = result + "\u000A"  // Line feed/Newline (LF)
          i = i + 2
        }
        'r' => {
          result = result + "\u000D"  // Carriage return (CR)
          i = i + 2
        }
        't' => {
          result = result + "\u0009"  // Horizontal tab (HT)
          i = i + 2
        }
        'v' => {
          result = result + "\u000B"  // Vertical tab (VT)
          i = i + 2
        }
        '\\' => {
          result = result + "\\"      // Backslash
          i = i + 2
        }
        '0' => {
          // Handle octal numbers
          let mut octal_num = ""
          let mut j = i + 2
          // Get up to 3 octal digits
          while j < s.length() && j < i + 5 && s[j] >= '0' && s[j] <= '7' {
            octal_num = octal_num + s_array[j].to_string()
            j = j + 1
          }
          if octal_num.length() > 0 {
            // Convert octal to decimal
            let dec_val = @strconv.parse_int?(octal_num, base=8)
            // Convert decimal to character
            result = result + Char::from_int(dec_val.unwrap()).to_string()
            i = j
          } else {
            result = result + "\\0"
            i = i + 2
          }
        }
        _ => {
          // Unknown escape sequence, keep as is
          result = result + "\\" + s_array[i + 1].to_string()
          i = i + 2
        }
      }
    } else {
      result = result + s_array[i].to_string()
      i = i + 1
    }
  }
  result
}

fn main {
  let args = @sys.get_cli_args()
 
  let parsed:Array[String] = []
  for arg in args{
    // println("parsing: " + arg)
    parsed.push(parse_special_char(arg))
  }
  
  println(String::concat(parsed, separator=" "))
}