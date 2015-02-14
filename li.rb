# This is my work on translating the lispy interpreter to Ruby
# Working on how to do proper imports

Env = Hash
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

class Environment
    def standard_env
        env = {
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
            'apply' => lambda { |x, *y| x[*y] },
            'begin' => lambda { |*x| x[-1] }, 
            'car' => lambda { |x| x[0] },
            'cdr' => lambda { |x| x[1, x.size] },
            'eq?' => lambda { |x, y| x === y },
            'equal?' => lambda { |x, y| x == y }, 
            'length' => lambda { |x| x.size },
            'list' => lambda { |*x| List[*x] },           
            'list?' => lambda { |x| x.is_a? List },
            'map' => lambda { |x, y| y.map { |z| x[z] } },
            'max' => lambda { |x| x.max },
            'min' => lambda { |x| x.min },
            'not' => lambda { |x| not x },
            'null?' => lambda { |x| x == [] },
            'procedure?' => lambda { |x| x.respond_to? 'call' },
            'round' => lambda { |x| x.round },
            'symbol?' => lambda { |x| x.is_a? SchemeSymbol },
        }
        return env
    end
end

