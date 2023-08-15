enum Token {
  case letKeyword
  case identifier(String)
  case assign
  case int(String)
  case semicolon
  case lparen
  case rparen
  case comma
  case plus
  case lbrace
  case rbrace
  case eof
  case illegal
  case function
  case bang
  case asterisk
  case slash
  case minus
  case lessThan
  case greaterThan
  case equal
  case notEqual
  case ifKeyword
  case elseKeyword
  case returnKeyword
  case trueKeyword
  case falseKeyword
}

let keywords: [String: Token] = [
  "fn": .function, "let": .letKeyword, "if": .ifKeyword, "else": .elseKeyword,
  "return": .returnKeyword, "true": .trueKeyword, "false": .falseKeyword,
]

let characters: [Character: Token] = [
  "(": .lparen, ")": .rparen, ",": .comma, "+": .plus, "{": .lbrace,
  "}": .rbrace, "-": .minus, "/": .slash, "*": .asterisk, "<": .lessThan,
  ">": .greaterThan, ";": .semicolon,
]

class Lexer: CustomStringConvertible {
  var input: String
  var position: Int
  var readPosition: Int
  var char: Character

  init(input: String) {
    self.input = input
    self.position = 0
    self.readPosition = 0
    self.char = "\u{200B}"
    readChar()
  }

  var description: String {
    return
      "Lexer: input='\(input)', position=\(position), readPosition=\(readPosition), char='\(char)'"
  }

  func readChar() {
    if readPosition >= input.count {
      char = "\u{200B}"
    } else {
      let index = input.index(input.startIndex, offsetBy: readPosition)
      char = input[index]
    }
    position = readPosition
    readPosition += 1
  }

  func peekChar() -> Character {
    if readPosition >= input.count {
      return "\u{200B}"
    } else {
      let index = input.index(input.startIndex, offsetBy: readPosition)
      return input[index]
    }
  }

  func getTokenFromCharacter(for char: Character) -> Token? {
    if let tok = characters[char] {
      return tok
    } else {
      return nil
    }
  }

  func nextToken() -> Token {
    let tok: Token

    skipWhitespace()

    if let token = getTokenFromCharacter(for: char) {
      tok = token
    } else {
      switch char {
      case "=":
        if peekChar() == "=" {
          readChar()
          tok = .equal
        } else {
          tok = .assign
        }
      case "!":
        if peekChar() == "=" {
          readChar()
          tok = .notEqual
        } else {
          tok = .bang
        }
      case "\u{200B}":
        tok = .eof
      default:
        if char.isLetter {
          let ident = readIdentifier()
          tok = lookupIdent(ident: ident)
          return tok
        } else if char.isNumber {
          let number = readNumber()
          tok = .int(number)
          return tok
        } else {
          tok = .illegal
        }
      }
    }
    readChar()
    return tok
  }

  func readNumber() -> String {
    let start = position
    while char.isNumber {
      readChar()
    }
    let startIndex = input.index(input.startIndex, offsetBy: start)
    let endIndex = input.index(input.startIndex, offsetBy: position)
    return String(input[startIndex..<endIndex])
  }

  func lookupIdent(ident: String) -> Token {
    if let tok = keywords[ident] {
      return tok
    } else {
      return .identifier(ident)
    }
  }

  func skipWhitespace() {
    while char == " " || char == "\t" || char == "\n" || char == "\r" {
      readChar()
    }
  }

  func readIdentifier() -> String {
    let start = position
    while char.isLetter {
      readChar()
    }
    let startIndex = input.index(input.startIndex, offsetBy: start)
    let endIndex = input.index(input.startIndex, offsetBy: position)
    return String(input[startIndex..<endIndex])
  }

}

func main() {
  let input = """
    let five = 5;
    let ten = 10;

    if (five != ten) {
        return true;
    };

    if (five == ten) {
        return false;
    };
    """
  let lexer = Lexer(input: input)
  while true {
    let tok = lexer.nextToken()
    print(tok)
    if case .eof = tok {
      break
    }
  }
}

main()
