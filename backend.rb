class Backend
  attr_writer :dbg
  def initialize(code)
    @code=code
    @dbg=false
    @pc=0
  end
  def run
    while true
      op=@code[@pc]
      break if op==nil
      inc=execute(op)
      @pc+=1 if inc
    end
  end
end
