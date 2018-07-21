require_relative "lexer.rb"
require_relative "token.rb"
require "pry"
class Parser
  @@tag_to_op={:ADD=>"+",:SUB=>"-",:MUL=>"*",:DIV=>"/"}
  attr_reader :output
  def initialize(string)
    @debug=false
    @tokens=Lexer.new(string).tokenize
    p @tokens if @debug
    @token=@tokens.shift
    @tmpid=1
    @output=[]
  end
  def parse()
    block()
    expected("EOF") if @token != nil
  end
  private
  def expected(str)
    puts "Error: #{str} Expected"
    begin
      raise StandardError
    rescue StandardError => e
      e.backtrace.shift
      puts e.backtrace
    end
    exit
  end
  def get_numb()
    expected("Number") if @token.class!=Number
    tok=@token
    @token=@tokens.shift
    p tok if @debug
    p [@token,@tokens].flatten if @debug
    return tok.val
  end
  def get_name()
    expected("Name") if @token.class!=Ident
    tok=@token
    @token=@tokens.shift
    p tok if @debug
    p [@token,@tokens].flatten if @debug
    return tok.val
  end
  def get_str()
    expected("String") if @token.class!=StrTok
    tok=@token
    @token=@tokens.shift
    p tok if @debug
    p [@token,@tokens].flatten if @debug
    return tok.strval
  end
  def match(tag)
    expected(tag) if @token==nil
    expected(tag) if @token.tag!=tag
    @token=@tokens.shift
    p tok if @debug
    p [@token,@tokens].flatten if @debug
  end
  def make_tmp()
    tmp="t#{@tmpid}"
    @tmpid+=1
    return tmp
  end
  def factor()
    case @token.tag
    when :IDENT
      name=get_name()
      tmp=make_tmp()
      if @token.tag==:OPEN_PAREN
        params=[]
        match(:OPEN_PAREN)
        while true
          break if @token.tag==:CLOSE_PAREN
          params.push expression()
          break if @token.tag!=:COMMA
          match(:COMMA)
        end
        match(:CLOSE_PAREN)
        params.each do |tmpvar|
          @output.push [nil,"param",tmpvar,nil]
        end
        @output.push [tmp,"call",name,nil]
      else
        @output.push [tmp,"=",name,nil]
      end
    when :OPEN_PAREN
      match(:OPEN_PAREN)
      tmp=expression()
      match(:CLOSE_PAREN)
    when :SUB
      match(:SUB)
      tmp=make_tmp()
      num=get_numb()
      @output.push [tmp,"=","-#{num}",nil]
    else
      tmp=make_tmp()
      if @token.class==StrTok
        val=get_str()
      else
        val=get_numb()
      end
      @output.push [tmp,"=",val,nil]
    end
    return tmp
  end
  def term()
    ops=[:MUL,:DIV]
    tmp=factor()
    oldtmp=tmp
    return tmp if @token==nil
    while ops.include? @token.tag
      tmp=make_tmp()
      op=@token.tag
      match(op)
      op=@@tag_to_op[op]
      fact=factor()
      @output.push [tmp,op,oldtmp,fact]
      oldtmp=tmp
      break if @token==nil
    end
    return tmp
  end
  def expression()
    ops=[:ADD,:SUB]
    tmp=term()
    oldtmp=tmp
    return tmp if @token==nil
    while ops.include? @token.tag
      tmp=make_tmp()
      op=@token.tag
      match(op)
      op=@@tag_to_op[op]
      trm=term()
      @output.push [tmp,op,oldtmp,trm]
      oldtmp=tmp
      break if @token==nil
    end
    return tmp
  end
  def assingment()
    name=get_name()
    match(:EQUALS)
    tmpvar=expression()
    @output.push [name,"=",tmpvar,nil]
  end
  def func()
    match(:DEF)
    name=@token.val
    match(:IDENT)
    match(:OPEN_CURL)
    @output.push [nil,"func",name,nil]
    block(:CLOSE_CURL)
    @output.push [nil,"return",nil,nil]
    @output.push [nil,"funcend",nil,nil]
  end
  def ret()
    match(:RETURN)
    tmpvar=expression()
    @output.push [nil,"return",tmpvar,nil]
  end
  def statement()
    if @token.tag==:IDENT and @tokens[0].tag==:EQUALS
      assingment()
      match(:SEMICOLON)
    elsif @token.tag==:DEF
      func()
    elsif @token.tag==:RETURN
      ret()
      match(:SEMICOLON)
    else
      expression()
      match(:SEMICOLON)
    end
  end
  def block(end_tok=nil)
    if end_tok
      while @token.tag!=end_tok
        statement()
      end
      match(end_tok)
    else
      while @token!=nil
        statement()
      end
    end
  end
end
