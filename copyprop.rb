class CopyProp
  def initialize(code)
    @code=code
  end
  def optimize()
    table={}
    i=0
    @code.clone.each do |quad|
      if quad[3]==nil and quad[1]=="="
        table[quad[0]]=quad[2]
      else
        if table.has_key? quad[2]
          while true
            replace=table[quad[2]]
            break if replace==nil
            quad[2]=replace
          end
        end
        if table.has_key? quad[3]
          while true
            replace=table[quad[3]]
            break if replace==nil
            quad[3]=replace
          end
        end
      end
      @code[i]=quad
      i+=1
    end
    return @code
  end
end
