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
