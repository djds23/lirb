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
        # Fix this somehow
        env = Env.new()  
        op = Operator
        operators = {
            '+' => lambda { |x, y| op.add(x, y) },
            '-' => lambda { |x, y| op.sub(x, y) },
            '*' => lambda { |x, y| op.mul(x, y) },
            '/' => lambda { |x, y| op.div(x, y) },
            '>' => lambda { |x, y| op.gt(x, y) },
            '<' => lambda { |x, y| op.lt(x, y) },
            '>=' => lambda { |x, y| op.gte(x, y) },
            '<=' => lambda { |x, y| op.lte(x, y) },
            '=' => lambda { |x, y|  op.eq(x, y) }
        }
        sm = SimpleMath
        fu = FuncUtils
        funcs = {
            'abs' => lambda { |x| sm.abs(x) },
            'append' => lambda { |x, y| op.add(x, y) },
            'apply' => lambda { |*x| fu.apply(*x) },
            'begin' => lambda { |*x| x[-1] }, 
            'car' => lambda { |x| x[0] },
            'cdr' => lambda { |x| x[1, x.size] },
            'eq?' => lambda { |x, y| x === y },
            'equal?' => lambda { |x, y| x == y }, 
            'length' => lambda { |x| x.size },
            'list' => lambda { |*x| List[*x] },           
        }
        env.merge!(operators)
        env.merge!(funcs)
        return env
    end
end

