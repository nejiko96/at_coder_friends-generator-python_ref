# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::PythonRef do
  it 'has a version number' do
    expect(AtCoderFriends::Generator::PythonRef::VERSION).not_to be nil
  end

  TMPL_DIR = File.realpath(File.join(__dir__, '..', '..', '..', 'templates'))

  subject(:generator) { described_class.new(cfg) }
  let(:cfg) { nil }

  describe '#select_template' do
    subject { generator.select_template(interactive) }

    context 'with default configuration' do
      context 'for interactive problems' do
        let(:interactive) { true }

        it 'returns template file name' do
          expect(subject).to eq(
            File.join(TMPL_DIR, 'python_ref_interactive.py')
          )
        end
      end

      context 'for other problems' do
        let(:interactive) { false }

        it 'returns template file name' do
          expect(subject).to eq(
            File.join(TMPL_DIR, 'python_ref_default.py')
          )
        end
      end
    end

    context 'with custom configuration' do
      let(:cfg) do
        {
          'default_template' => 'customized_default.py',
          'interactive_template' => 'customized_interactive.py'
        }
      end

      context 'for interactive problems' do
        let(:interactive) { true }

        it 'returns template file name' do
          expect(subject).to eq('customized_interactive.py')
        end
      end

      context 'for other problems' do
        let(:interactive) { false }

        it 'returns template file name' do
          expect(subject).to eq('customized_default.py')
        end
      end
    end
  end

  describe '#gen_consts' do
    subject { generator.gen_consts(constants) }
    let(:constants) do
      [
        AtCoderFriends::Problem::Constant.new('N', :max, '10,000'),
        AtCoderFriends::Problem::Constant.new(nil, :mod, '998,244,353')
      ]
    end

    it 'generates constant decls' do
      expect(subject).to match(
        [
          'MOD = 998244353'
        ]
      )
    end
  end

  describe '#gen_decl' do
    subject { generator.gen_decl(inpdef) }
    let(:inpdef) do
      AtCoderFriends::Problem::InputFormat.new(container, item, names, size)
    end
    let(:names) { %w[A] }
    let(:size) { [] }

    context 'for a plain number' do
      let(:container) { :single }
      let(:item) { :number }
      it 'generates decl' do
        expect(subject).to eq('A = int(input())')
      end
    end

    context 'for plain numbers' do
      let(:container) { :single }
      let(:item) { :number }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq('A, B = map(int, input().split())')
      end
    end

    context 'for a plain string' do
      let(:container) { :single }
      let(:item) { :string }
      it 'generates decl' do
        expect(subject).to eq('A = input()')
      end
    end

    context 'for plain strings' do
      let(:container) { :single }
      let(:item) { :string }
      let(:names) { %w[A B] }
      it 'generates decl' do
        expect(subject).to eq('A, B = input().split()')
      end
    end

    context 'for a horizontal array of numbers' do
      let(:container) { :harray }
      let(:item) { :number }
      it 'generates decl' do
        expect(subject).to eq('As = map(int, input().split())')
      end
    end

    context 'for a horizontal array of strings' do
      let(:container) { :harray }
      let(:item) { :string }
      it 'generates decl' do
        expect(subject).to eq('As = input().split()')
      end
    end

    context 'for a horizontal array of characters' do
      let(:container) { :harray }
      let(:item) { :char }
      it 'generates decl' do
        expect(subject).to eq('As = input()')
      end
    end

    context 'for single vertical array of numbers' do
      let(:container) { :varray }
      let(:item) { :number }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('As = [int(input()) for _ in range(N)]')
      end
    end

    context 'for single vertical array of strings' do
      let(:container) { :varray }
      let(:item) { :string }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to eq('As = [input() for _ in range(N)]')
      end
    end

    context 'for multiple vertical array of numbers' do
      let(:container) { :varray }
      let(:item) { :number }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'As = [None for _ in range(N)]',
            'Bs = [None for _ in range(N)]',
            'for i in range(N):',
            '    As[i], Bs[i] = map(int, input().split())'
          ]
        )
      end
    end

    context 'for multple vertical array of strings' do
      let(:container) { :varray }
      let(:item) { :string }
      let(:names) { %w[A B] }
      let(:size) { %w[N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'As = [None for _ in range(N)]',
            'Bs = [None for _ in range(N)]',
            'for i in range(N):',
            '    As[i], Bs[i] = input().split()'
          ]
        )
      end
    end

    context 'for a matrix of numbers' do
      let(:container) { :matrix }
      let(:item) { :number }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq(
          'Ass = [map(int, input().split()) for _ in range(R)]'
        )
      end
    end

    context 'for a matrix of strings' do
      let(:container) { :matrix }
      let(:item) { :string }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq('Ass = [input().split() for _ in range(R)]')
      end
    end

    context 'for a matrix of characters' do
      let(:container) { :matrix }
      let(:item) { :char }
      let(:size) { %w[R C] }
      it 'generates decl' do
        expect(subject).to eq('Ass = [input() for _ in range(R)]')
      end
    end
  end

  describe '#gen_output' do
    subject { generator.gen_output(vs) }

    context 'for a general problem' do
      let(:vs) { nil }

      it 'generates output script' do
        expect(subject).to eq('print(ans)')
      end
    end

    context 'for a binary problem' do
      let(:vs) { %w[Yes No] }

      it 'generates output script' do
        expect(subject).to eq("print('Yes' if cond else 'No')")
      end
    end
  end

  describe '#generate' do
    subject { generator.generate(pbm) }
    let(:pbm) do
      AtCoderFriends::Problem.new('A') do |pbm|
        pbm.formats = formats
        pbm.constants = constants
        pbm.options.interactive = interactive
      end
    end

    context 'for a general problem' do
      before do
        allow(pbm).to receive(:url) do
          'https://atcoder.jp/contests/practice/tasks/practice_1'
        end
      end
      let(:formats) do
        [
          AtCoderFriends::Problem::InputFormat.new(:single, :number, %w[N]),
          AtCoderFriends::Problem::InputFormat.new(
            :varray, :number, %w[x y], %w[N]
          ),
          AtCoderFriends::Problem::InputFormat.new(:single, :string, %w[Q]),
          AtCoderFriends::Problem::InputFormat.new(
            :harray, :string, %w[a], %w[Q]
          )
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '100000'),
          AtCoderFriends::Problem::Constant.new(nil, :mod, '10^9+7')
        ]
      end
      let(:interactive) { false }

      it 'generates ruby source' do
        expect(subject).to eq(
          <<~SRC
            # https://atcoder.jp/contests/practice/tasks/practice_1

            MOD = 10**9+7

            N = int(input())
            xs = [None for _ in range(N)]
            ys = [None for _ in range(N)]
            for i in range(N):
                xs[i], ys[i] = map(int, input().split())
            Q = input()
            as = input().split()

            print(ans)
          SRC
        )
      end
    end

    context 'for an interactive problem' do
      before do
        allow(pbm).to receive(:url) do
          'https://atcoder.jp/contests/practice/tasks/practice_2'
        end
      end
      let(:formats) do
        [
          AtCoderFriends::Problem::InputFormat.new(:single, :number, %w[N Q])
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '26'),
          AtCoderFriends::Problem::Constant.new(nil, :mod, '2^32')
        ]
      end
      let(:interactive) { true }

      it 'generates ruby source' do
        expect(subject).to eq(
          <<~'SRC'
            # https://atcoder.jp/contests/practice/tasks/practice_2

            MOD = 2**32

            N, Q = map(int, input().split())

            print(ans)
          SRC
        )
      end
    end
  end
end
