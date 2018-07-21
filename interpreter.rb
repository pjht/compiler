require_relative "backend.rb"
class Interpreter < Backend
  def initialize(code)
    @vartable={}
    @paramtable=[]
    @functable={}
    @retstack=[]
    @envstack=[]
    @noinc=["call","return"]
    @infunc=false
    super(code)
  end
  def execute(op)
    if @infunc
      if op[1]=="funcend"
        @infunc=false
      end
      return true
    end
    puts "Running #{op}"
    case op[1]
    when "="
      @vartable[op[0]]=toval(op[2])
    when "+","-","*","/"
      op[2]=toval(op[2])
      op[3]=toval(op[3])
      @vartable[op[0]]=op[2].send(op[1],op[3])
    when "param"
      @paramtable.push toval(op[2])
    when "call"
      result=nil
      case op[2]
      when "puts"
        puts @paramtable.shift
        result=1
        @pc+=1
      when "gets"
        print "Enter number:"
        result=gets.chomp!.to_i
        @pc+=1
      else
        if @functable.has_key? op[2]
          @retstack.push([@pc+1,op[0]])
          @pc=@functable[op[2]]
          @envstack.push @vartable
          @vartable={}
        end
      end
      if result and op[0]
        @vartable[op[0]]=result
      end
    when "func"
      @functable[op[2]]=@pc+1
      @infunc=true
    when "return"
      info=@retstack.pop()
      @pc=info[0]
      if op[2]
        rval=toval(op[2])
      else
        rval=nil
      end
      @vartable=@envstack.pop()
      @vartable[info[1]]=rval
    end
    puts "Vars:#{@vartable}"
    puts "Params:#{@paramtable}"
    puts "Funcs:#{@functable}"
    return !(@noinc.include? op[1])
  end
  private
  def toval(obj)
    if obj.is_a? Integer
      return obj
    elsif /^\d+/.match obj
      return obj.to_i
    elsif /^"([^"]+)"/.match obj
      return $1
    else
      return @vartable[obj]
    end
  end
end
