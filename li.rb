# This is my work on translating the lispy interpreter to Ruby

L_Symbol = String
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

token_str = "(begin (define r 10) (* pi (* r r)))" 
test_tokenize = tokenize(token_str) === ['(', 'begin', '(', 'define', 'r', '10', ')', '(', '*', 'pi', '(', '*', 'r', 'r', ')', ')', ')'] 

program = "(begin (define r 10) (* pi (* r r)))"
test_parse = parse(program) === ['begin', ['define', 'r', 10], ['*', 'pi', ['*', 'r', 'r']]]
