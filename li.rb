# This is my work on translating the lispy interpreter to Ruby
# Working on how to do proper imports
require_relative 'utils'

SchemeSymbol = String
List = Array
Number = [Integer, Float]

class Interperter

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
end

Env = Hash
class Environment
    def standard_env
        math_methods = Math.public_methods
        math_names = math_methods.map { |meth| meth.to_s }
        # this pollutes default Env with class methods on math
        # Fix this somehow
        env = Env[math_names.zip math_methods]    
        op = Operator
        operators = {
            '+' => lambda { |x, y| op.add(x, y) },
=begin
      
            '-' => op.sub,
            '*' => op.mul,
            '/' => op.div,
            '>' => op.gt,
            '<' => op.lt,
            '>=' => op.gte,
            '<=' => op.lte,
            '=' => op.eq,
        }
        sm = SimpleMath.new()
        fu = FuncUtils.new()
        funcs = {
            'abs' => sm.abs,
            'append' => op.add,
            'apply' => fu.apply,
=end
        }
        env.merge!(operators)
        return env
    end
end

