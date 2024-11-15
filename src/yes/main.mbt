fn main {
  let args = @sys.get_cli_args()
  let mut col: String = "y"
  if args.length() > 0 {
      col = String::concat(args)
  }
  for {
    println(col)
  }
}
