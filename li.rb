# This is my work on translating the lispy interpreter to Ruby
# Working on how to do proper imports
# require lirb/operators
require_relative 'operators' 

SchemeSymbol = String
List = Array
Number = [Integer, Float]


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

Env = Hash

def standard_env
    math_methods = Math.public_methods
    math_names = math_methods.map { |meth| meth.to_s }
    # this pollutes default Env with class methods on math
    # Fix this somehow
    env = Env[math_names.zip math_methods]    
    #env.merge({
       # 'x' =>  
end

token_str = "(begin (define r 10) (* pi (* r r)))" 
test_tokenize = tokenize(token_str) === ['(', 'begin', '(', 'define', 'r', '10', ')', '(', '*', 'pi', '(', '*', 'r', 'r', ')', ')', ')'] 

program = "(begin (define r 10) (* pi (* r r)))"
test_parse = parse(program) === ['begin', ['define', 'r', 10], ['*', 'pi', ['*', 'r', 'r']]]