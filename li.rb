# This is my work on translating the lispy interpreter to Ruby
# Working on how to do proper imports

SchemeSymbol = String
List = Array
Number = [Integer, Float]

class Env < Hash
    def initialize(keys=[], vals=[], outer=nil)
        @outer = outer
        keys.zip(vals).each { |p| store(*p) }
    end
    def [](name) super(name) || @outer[name] end
    def set(name, value) key?(name) ? store(name, value) : @outer.set(name, value) end
end

def add_globals(env)
    env.merge!({
        'pi' => Math::PI,
        '+' => lambda { |x, y| x + y },
        '-' => lambda { |x, y| x - y },
        '*' => lambda { |x, y| x * y },
        '/' => lambda { |x, y| x / y },
        '>' => lambda { |x, y| x > y },
        '<' => lambda { |x, y| x < y },
        '>=' => lambda { |x, y| x >= y },
        '<=' => lambda { |x, y| x <= y },
        '=' => lambda { |x, y| x == y },
        'abs' => lambda { |x| x.abs },
        'append' => lambda { |x, y| x + y },
        'apply' => lambda { |x, *y| x.call(*y) },
        'begin' => lambda { |*x| x[-1] }, 
        'car' => lambda { |x| x[0] },
        'cdr' => lambda { |x| x[1, x.size] },
        'eq?' => lambda { |x, y| x === y },
        'equal?' => lambda { |x, y| x == y }, 
        'length' => lambda { |x| x.size },
        'list' => lambda { |*x| List[*x] },           
        'list?' => lambda { |x| x.is_a? List },
        'map' => lambda { |x, y| y.map { |z| x.call(z) } },
        'max' => lambda { |x| x.max },
        'min' => lambda { |x| x.min },
        'not' => lambda { |x| not x },
        'null?' => lambda { |x| x == [] },
        'procedure?' => lambda { |x| x.respond_to? 'call' },
        'round' => lambda { |x| x.round },
        'symbol?' => lambda { |x| x.is_a? SchemeSymbol },
        'print' => lambda { |x| puts x },
    })
end

$global_env = add_globals(Env.new())

class Procedure
    def initialize(params, body, env)
        @params = params
        @body = body
        @env = env
    end
    
    def call(*args)
        _eval(@body, Env.new(@params, outer=@env,  *args))
    end
end

def _eval(input, env=$global_env)
    if input.is_a? SchemeSymbol 
        return env[input]
    elsif not input.is_a? List
        return input
    elsif input[0] == 'quote'
        _, exp = input
        return exp
    elsif input[0] == 'if'
        _, test, conseq, alt = input
        exp = _eval(test, env) ? conseq : alt
        return _eval(exp, env)
    elsif input[0] == 'define'
        _, var, exp = input
        env.merge!({var =>  _eval(exp, env)})
    elsif input[0] == 'set!'
        _, var, exp = input
        env[var] = _eval(exp, env)
    elsif input[0] == 'lambda'
        _, params, body = input
        return Procedure.new(params, body, env)
    else
        procedure = _eval(input[0], env)
        args = input[1, input.size].map { |x| _eval(x, env) }
        puts "this #{input[0]} with #{args}"
        return procedure.call(*args)
    end
end


class Interpreter

    def tokenize str
        str.gsub('(', ' ( ').gsub(')', ' ) ').split(' ')
    end

    def atom token
        begin
            Integer(token)
        rescue ArgumentError, TypeError
            begin
                Float(token)
            rescue ArgumentError, TypeError
                String(token)
            end
        end
    end 

    def read_from_tokens tokens
        if tokens.empty?
            raise SyntaxError, "Unexpected EOF"
        end
        token = tokens.shift
        if token == "("
            expressions = []
            while tokens[0] != ')'
                expressions.push(read_from_tokens(tokens))
            end
            tokens.shift # pop off trailing ')'
            return expressions
        elsif ')' == token
            raise SyntaxError, "Unexpected )" 
        else 
            return atom(token) 
        end 
    end 

    def parse(program)
        read_from_tokens(tokenize(program))
    end

    def raw_input(prompt="")
        print prompt
        gets
    end

    def repl(prompt="lirb> ")
        env = $global_env 
        while true 
            input = raw_input(prompt)
            puts input
            if input.strip == "exit" 
                break  
            elsif input.strip == ""
            else    
                output = parse(input.strip)
                result =  _eval(output, env)
                puts result
            end            
        end
    end
end

Interpreter.new().repl
