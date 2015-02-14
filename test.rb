require_relative "li.rb"
require "test/unit"


class TestParser < Test::Unit::TestCase
    def test_tokenizer
        token_str = "(begin (define r 10) (* pi (* r r)))" 
        assert_equal(Interperter.new().tokenize(token_str),  ['(', 'begin', '(', 'define', 'r', '10', ')', '(', '*', 'pi', '(', '*', 'r', 'r', ')', ')', ')']) 
    end
    def test_make_ast
        program = "(begin (define r 10) (* pi (* r r)))"
        assert_equal(Interperter.new().parse(program), ['begin', ['define', 'r', 10], ['*', 'pi', ['*', 'r', 'r']]])
    end
end

class TestEnvironment < Test::Unit::TestCase
    def test_addition_in_env
        env = Environment.new().standard_env()
        assert_equal(2, env['+'][1,1])
    end

    def test_make_list
        env = Environment.new().standard_env()
        assert_equal([1,2,3], env['list'][1,2,3])
    end

    def test_map
        env = Environment.new().standard_env()
        list = env['list'][1,2,3]
        add1 = lambda { |x| env['+'][1, x] }
        new_list = env['map'][add1, list]
        assert_equal([2,3,4], new_list)
    end

    def test_callable
        e = Environment.new().standard_env()
        assert !(e['procedure?'][nil])
        assert e['procedure?'][lambda { |x| x+1}]
    end
end
