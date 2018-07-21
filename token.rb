class Token
  attr_reader :tag
  def initialize(tag)
    @tag=tag
  end
end

class Number < Token
  attr_reader :val
  def initialize(lexeme)
    super(:NUMB)
    @val=lexeme.to_i
  end
end

class Ident < Token
  attr_reader :val
  def initialize(lexeme)
    super(:IDENT)
    @val=lexeme
  end
end

class StrTok < Token
  attr_reader :strval
  def initialize(lexeme)
    super(:STRING)
    @strval=lexeme
  end
end
