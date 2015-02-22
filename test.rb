require_relative "li.rb"
require "test/unit"


class TestEnvironment < Test::Unit::TestCase
    def test_addition_in_env
        env = add_globals(Env.new())
        assert_equal(2, env['+'][1,1])
    end

    def test_make_list
        env = add_globals(Env.new())
        assert_equal([1,2,3], env['list'][1,2,3])
    end

    def test_map
        env = add_globals(Env.new())
        list = env['list'][1,2,3]
        add1 = lambda { |x| env['+'][1, x] }
        new_list = env['map'][add1, list]
        assert_equal([2,3,4], new_list)
    end

    def test_callable
        e = add_globals(Env.new())
        assert !(e['procedure?'][nil])
        assert e['procedure?'][lambda { |x| x+1}]
    end
end


class TestInterpreter < Test::Unit::TestCase

    def test_tokenizer
        token_str = "(begin (define r 10) (* pi (* r r)))" 
        assert_equal(Interpreter.new().tokenize(token_str),  ['(', 'begin', '(', 'define', 'r', '10', ')', '(', '*', 'pi', '(', '*', 'r', 'r', ')', ')', ')']) 
    end

    def test_make_ast
        program = "(begin (define r 10) (* pi (* r r)))"
        assert_equal(Interpreter.new().parse(program), ['begin', ['define', 'r', 10], ['*', 'pi', ['*', 'r', 'r']]])
    end

    def test_eval
        program = "(begin (define r 10) (* pi (* r r)))"
        scheme = Interpreter.new()
        ast = scheme.parse(program)
        rv = _eval(ast)
        assert_equal(rv, 314.1592653589793)
    end

    def test_nested_evals
        program = "(begin (+ 100 (+ 100 (+ 100 100))))"
        scheme = Interpreter.new()
        ast = scheme.parse(program)
        rv = _eval(ast)
        assert_equal(rv, 400)
    end

    def test_procedures_and_envs
        program = "(begin 
                    (define fact 
                    (lambda (n) (if 
                        (<= n 1) 1 (* n (fact (- n 1))))))    
                    (fact 10))"
        scheme = Interpreter.new()
        ast = scheme.parse(program)
        rv = _eval(ast)
        assert_equal(rv, 3628800)
    end

    def test_procedures_and_envs_1
        program = "(begin
                    (define fib 
                        (lambda (n) 
                          (if (< n 2) 
                              1 
                              (+ (fib (- n 1)) (fib (- n 2))))))
                              (fib 10))"
        scheme = Interpreter.new()
        ast = scheme.parse(program)
        rv = _eval(ast)
        assert_equal(rv, 89)
    end
end


