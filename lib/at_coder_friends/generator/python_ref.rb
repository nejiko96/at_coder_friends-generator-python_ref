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
        src = embed_lines(src, '### CONSTS ###', gen_consts)
        embed_lines(src, '### DCLS ###', gen_decls)
      end

      def gen_consts(constants = pbm.constants)
        constants
          .select { |c| c.type == :mod }
          .map { |c| gen_mod(c) }
      end

      def gen_mod(c)
        v = c.value.gsub('^', '**').gsub(',', '_')
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
        when :varray_matrix, :matrix_varray
          gen_cmb_decl(inpdef)
        when :vmatrix
          gen_vmatrix_decl(inpdef)
        when :hmatrix
          gen_hmatrix_decl(inpdef)
        end
      end

      def gen_single_decl(inpdef)
        names = inpdef.names
        dcl = names.join(', ')
        expr = gen_expr(inpdef, names.size > 1)
        "#{dcl} = #{expr}"
      end

      def gen_harray_decl(inpdef)
        v = inpdef.names[0]
        dcl = "#{v}s"
        expr = gen_expr(inpdef, true)
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
        expr = gen_expr(inpdef, false)
        "#{dcl} = [#{expr} for _ in range(#{sz})]"
      end

      def gen_varray_n_decl(inpdef)
        names = inpdef.names
        sz = inpdef.size[0]
        dcl = names.map { |v| "#{v}s[i]" }.join(', ')
        expr = gen_expr(inpdef, true)
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
        expr = gen_expr(inpdef, true)
        "#{decl} = [#{expr} for _ in range(#{sz})]"
      end

      def gen_cmb_decl(inpdef)
        mx = inpdef.container == :varray_matrix ? -1 : 0
        vs = inpdef.names.map { |v| "#{v}s" }
        vs[mx] += 's'
        sz = inpdef.size[0]
        dcls = vs.map { |v| "#{v}[i]" }
        dcls[mx] = "*#{dcls[mx]}" unless inpdef.item == :char
        dcl = dcls.join(', ')
        expr = gen_cmb_expr(inpdef)
        ret = []
        ret += vs.map { |v| "#{v} = [None for _ in range(#{sz})]" }
        ret << "for i in range(#{sz}):"
        ret << "    #{dcl} = #{expr}"
        ret
      end

      def gen_vmatrix_decl(inpdef)
        names = inpdef.names
        sz1, sz2 = inpdef.size
        dcl = names.map { |v| "#{v}ss[i][j]" }.join(', ')
        expr = gen_expr(inpdef, true)
        ret = []
        ret += names.map do |v|
          "#{v}ss = [[None for _ in range(#{sz2})] for _ in range(#{sz1})]"
        end
        ret << "for i in range(#{sz1}):"
        ret << "    for j in range(#{sz2}):"
        ret << "        #{dcl} = #{expr}"
        ret
      end

      def gen_hmatrix_decl(inpdef)
        names = inpdef.names
        sz = inpdef.size[0]
        dcls = names.map { |v| "#{v}ss[i]" }
        expr = gen_expr(inpdef, true)
        ret = []
        ret += names.map { |v| "#{v}ss = [None for _ in range(#{sz})]" }
        ret << "for i in range(#{sz}):"
        ret << "    line = #{expr}"
        ret += dcls.map.with_index do |dcl, i|
          "    #{dcl} = line[#{i}::#{dcls.size}]"
        end
        ret
      end

      def gen_expr(inpdef, split)
        read = gen_read(inpdef.delim)
        case inpdef.item
        when :number
          split ? "list(map(int, #{read}.split()))" : "int(#{read})"
        when :decimal
          split ? "list(map(float, #{read}.split()))" : "float(#{read})"
        when :string
          split ? "#{read}.split()" : read
        when :char
          read
        end
      end

      def gen_cmb_expr(inpdef)
        read = gen_read(inpdef.delim)
        case inpdef.item
        when :number
          "list(map(int, #{read}.split()))"
        when :decimal
          "list(map(float, #{read}.split()))"
        when :string, :char
          "#{read}.split()"
        end
      end

      def gen_read(delim)
        sub = delim.chars.map { |d| ".replace('#{d}', ' ')" }.join
        "input()#{sub}"
      end
    end
  end
end
