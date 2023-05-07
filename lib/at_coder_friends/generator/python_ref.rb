# frozen_string_literal: true

require 'at_coder_friends'
require 'at_coder_friends/generator/python_ref/version'

module AtCoderFriends
  module Generator
    # Python variable declaration generator

    # generates Python source from problem description
    class PythonRef < Base
      include PythonRefConstants
      include CommonFragmentMixin

      ACF_HOME = File.realpath(File.join(__dir__, '..', '..', '..'))
      TMPL_DIR = File.join(ACF_HOME, 'templates')
      TEMPLATE = File.join(TMPL_DIR, 'python_ref.py.erb')
      FRAGMENTS = File.realpath(File.join(TMPL_DIR, 'python_ref_fragments.yml'))
      ATTRS = Attributes.new(:py, TEMPLATE, FRAGMENTS)

      def attrs
        ATTRS
      end

      def constants
        super.select { |c| c.type == :mod }
      end

      # deprecated, use ERB syntax
      def render(src)
        src = embed_lines(src, '### CONSTS ###', gen_consts)
        embed_lines(src, '### DCLS ###', gen_decls)
      end
    end
  end
end
