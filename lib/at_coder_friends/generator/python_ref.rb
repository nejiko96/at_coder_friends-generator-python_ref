# frozen_string_literal: true

require 'at_coder_friends'
require 'at_coder_friends/generator/python_ref/version'

module AtCoderFriends
  module Generator
    # generates Python source from problem description
    class PythonRef < Base
      include PythonRefConstants

      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      DEFAULT_TMPL = File.join(TMPL_DIR, 'python_ref.py.erb')
      ATTRS = Attributes.new(:py, DEFAULT_TMPL)

      def attrs
        ATTRS
      end

      def render(src)
        src = embed_lines(src, '### URL ###', [pbm.url])
        src = embed_lines(src, '### CONSTS ###', gen_consts)
        src = embed_lines(src, '### DCLS ###', gen_decls)
        src
      end

      def gen_consts(constants = pbm.constants)
        constants
          .select { |c| c.type == :mod }
          .map { |c| gen_mod(c) }
      end

      def gen_mod(c)
        # underscores in numeric literals is available from Python3.6
        v = c.value.gsub('^', '**').gsub(',', '')
        "MOD = #{v}"
      end

      def gen_decls(inpdefs = pbm.formats)
        inpdefs.map { |inpdef| gen_decl(inpdef) }.flatten
      end

      def gen_decl(inpdef)
        case inpdef.container
        when :single
          gen_single_decl(inpdef)
        when :harray
          gen_harray_decl(inpdef)
        when :varray
          gen_varray_decl(inpdef)
        when :matrix
          gen_matrix_decl(inpdef)
        when :varray_matrix
          gen_varray_matrix_decl(inpdef)
        end
      end

      def gen_single_decl(inpdef)
        names = inpdef.names
        dcl = names.join(', ')
        expr = gen_expr(inpdef.item, names.size > 1)
        "#{dcl} = #{expr}"
      end

      def gen_harray_decl(inpdef)
        v = inpdef.names[0]
        dcl = "#{v}s"
        expr = gen_expr(inpdef.item, true)
        "#{dcl} = #{expr}"
      end

      def gen_varray_decl(inpdef)
        if inpdef.names.size == 1
          gen_varray_1_decl(inpdef)
        else
          gen_varray_n_decl(inpdef)
        end
      end

      def gen_varray_1_decl(inpdef)
        v = inpdef.names[0]
        sz = inpdef.size[0]
        dcl = "#{v}s"
        expr = gen_expr(inpdef.item, false)
        "#{dcl} = [#{expr} for _ in range(#{sz})]"
      end

      def gen_varray_n_decl(inpdef)
        names = inpdef.names
        sz = inpdef.size[0]
        dcl = names.map { |v| "#{v}s[i]" }.join(', ')
        expr = gen_expr(inpdef.item, true)
        ret = []
        ret += names.map { |v| "#{v}s = [None for _ in range(#{sz})]" }
        ret << "for i in range(#{sz}):"
        ret << "    #{dcl} = #{expr}"
        ret
      end

      def gen_matrix_decl(inpdef)
        v = inpdef.names[0]
        sz = inpdef.size[0]
        decl = "#{v}ss"
        expr = gen_expr(inpdef.item, true)
        "#{decl} = [#{expr} for _ in range(#{sz})]"
      end

      def gen_varray_matrix_decl(inpdef)
        vs = inpdef.names.map { |v| "#{v}s" }
        vs[-1] += 's'
        sz = inpdef.size[0]
        dcls = vs.map { |v| "#{v}[i]" }
        dcls[-1] = '*' + dcls[-1] unless inpdef.item == :char
        dcl = dcls.join(', ')
        expr = gen_varray_matrix_expr(inpdef.item)
        ret = []
        ret += vs.map { |v| "#{v} = [None for _ in range(#{sz})]" }
        ret << "for i in range(#{sz}):"
        ret << "    #{dcl} = #{expr}"
        ret
      end

      def gen_expr(item, split)
        case item
        when :number
          split ? 'list(map(int, input().split()))' : 'int(input())'
        when :string
          split ? 'input().split()' : 'input()'
        when :char
          'input()'
        end
      end

      def gen_varray_matrix_expr(item)
        case item
        when :number
          'list(map(int, input().split()))'
        when :string, :char
          'input().split()'
        end
      end
    end
  end
end
