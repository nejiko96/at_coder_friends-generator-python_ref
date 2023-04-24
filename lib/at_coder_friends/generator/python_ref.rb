# frozen_string_literal: true

require 'at_coder_friends'
require 'at_coder_friends/generator/python_ref/version'

module AtCoderFriends
  module Generator
    # Python variable declaration generator
    class PythonRefDeclFragment < InputFormatFragment
      def generate
        main
      end

      def main
        render('main', decl_type)
      end

      def input
        render('input', item.to_s, multi_values? ? 'multi' : 'single')
      end

      def decl_type
        case container
        when :varray
          vs.size > 1 ? 'varray_n' : 'varray_1'
        else
          container.to_s
        end
      end

      def multi_values?
        case container
        when :single, :varray
          vs.size > 1 && item != :char
        when :harray, :matrix
          item != :char
        else
          true
        end
      end
    end

    # generates Python source from problem description
    class PythonRef < Base
      include PythonRefConstants

      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      DEFAULT_TMPL = File.join(TMPL_DIR, 'python_ref.py.erb')
      FRAGMENTS = File.realpath(File.join(TMPL_DIR, 'python_ref_fragments.yml'))
      ATTRS = Attributes.new(:py, DEFAULT_TMPL, FRAGMENTS)

      def attrs
        ATTRS
      end

      # deprecated, use ERB syntax
      def render(src)
        src = embed_lines(src, '### CONSTS ###', gen_consts)
        embed_lines(src, '### DCLS ###', gen_decls)
      end

      def gen_consts(constants = pbm.constants)
        constants
          .select { |c| c.type == :mod }
          .map { |c| gen_const(c) }
      end

      def gen_const(c)
        ConstFragment.new(c, fragments['constant']).generate
      end

      def gen_decls(inpdefs = pbm.formats)
        inpdefs.map { |inpdef| gen_decl(inpdef).split("\n") }.flatten
      end

      def gen_decl(inpdef)
        PythonRefDeclFragment.new(inpdef, fragments['declaration']).generate
      end
    end
  end
end
