require "strscan"
require_relative "token.rb"
class Lexer
  def initialize(string)
    @scan=StringScanner.new(string)
    @line=0
  end
  def next_token()
    return nil if @scan.eos?
    lexeme=@scan.scan(/\n/)
    if lexeme
      @line+=1
      return next_token
    end
    lexeme=@scan.scan(/\s+/)
    return next_token if lexeme
    lexeme=@scan.scan(/\(/)
    return Token.new(:OPEN_PAREN) if lexeme
    lexeme=@scan.scan(/\)/)
    return Token.new(:CLOSE_PAREN) if lexeme
    lexeme=@scan.scan(/\{/)
    return Token.new(:OPEN_CURL) if lexeme
    lexeme=@scan.scan(/\}/)
    return Token.new(:CLOSE_CURL) if lexeme
    lexeme=@scan.scan(/\+/)
    return Token.new(:ADD) if lexeme
    lexeme=@scan.scan(/\-/)
    return Token.new(:SUB) if lexeme
    lexeme=@scan.scan(/\*/)
    return Token.new(:MUL) if lexeme
    lexeme=@scan.scan(/\//)
    return Token.new(:DIV) if lexeme
    lexeme=@scan.scan(/=/)
    return Token.new(:EQUALS) if lexeme
    lexeme=@scan.scan(/,/)
    return Token.new(:COMMA) if lexeme
    lexeme=@scan.scan(/;/)
    return Token.new(:SEMICOLON) if lexeme
    lexeme=@scan.scan(/"/)
    return string() if lexeme
    lexeme=@scan.scan(/def/)
    return Token.new(:DEF) if lexeme
    lexeme=@scan.scan(/return/)
    return Token.new(:RETURN) if lexeme
    lexeme=@scan.scan(/\d+/)
    return Number.new(lexeme) if lexeme
    lexeme=@scan.scan(/\w+/)
    return Ident.new(lexeme) if lexeme
    puts "Error: Cannot match #{@scan.rest}"
    exit
  end
  def tokenize()
    prg=[]
    while true
      token=next_token
      return prg if token==nil
      prg.push token
    end
  end
  private
  def string()
    lexeme=@scan.scan(/\[^"]*/)
    ok=@scan.scan(/"/)
    if ok==nil
      puts "Error: Unterminated string \"#{lexeme} on line #{@line}"
    end
    return StrTok.new('"'+lexeme+'"')
  end
end
