# frozen_string_literal: true

RSpec.describe AtCoderFriends::Generator::PythonRef do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  subject(:generator) { described_class.new(cfg) }
  let(:cfg) { nil }

  describe '#process' do
    subject { generator.process(pbm) }
    let(:pbm) { AtCoderFriends::Problem.new('A') }
    let(:ext) { pbm.sources[0].ext }

    it 'returns generator specific extension' do
      subject
      expect(ext).to match(:py)
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
        expect(subject).to eq('A, B = list(map(int, input().split()))')
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
        expect(subject).to eq('As = list(map(int, input().split()))')
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
            '    As[i], Bs[i] = list(map(int, input().split()))'
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
          'Ass = [list(map(int, input().split())) for _ in range(R)]'
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

    context 'for a vertical array and a matrix of numbers' do
      let(:container) { :varray_matrix }
      let(:item) { :number }
      let(:names) { %w[K A] }
      let(:size) { %w[N K_N] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'Ks = [None for _ in range(N)]',
            'Ass = [None for _ in range(N)]',
            'for i in range(N):',
            '    Ks[i], *Ass[i] = list(map(int, input().split()))'
          ]
        )
      end
    end

    context 'for a vertical array and a matrix characters' do
      let(:container) { :varray_matrix }
      let(:item) { :char }
      let(:names) { %w[K p] }
      let(:size) { %w[Q 26] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'Ks = [None for _ in range(Q)]',
            'pss = [None for _ in range(Q)]',
            'for i in range(Q):',
            '    Ks[i], pss[i] = input().split()'
          ]
        )
      end
    end

    context 'for a matrix and a vertical array of numbers' do
      let(:container) { :matrix_varray }
      let(:item) { :number }
      let(:names) { %w[city cost] }
      let(:size) { %w[M 2] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'cityss = [None for _ in range(M)]',
            'costs = [None for _ in range(M)]',
            'for i in range(M):',
            '    *cityss[i], costs[i] = list(map(int, input().split()))'
          ]
        )
      end
    end

    context 'for vertically expanded matrices(number)' do
      let(:container) { :vmatrix }
      let(:item) { :number }
      let(:names) { %w[idol p] }
      let(:size) { %w[1 C_1] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'idolss = [[None for _ in range(C_1)] for _ in range(1)]',
            'pss = [[None for _ in range(C_1)] for _ in range(1)]',
            'for i in range(1):',
            '    for j in range(C_1):',
            '        idolss[i][j], pss[i][j] = list(map(int, input().split()))'
          ]
        )
      end
    end

    context 'for horizontally expanded matrices(number)' do
      let(:container) { :hmatrix }
      let(:item) { :number }
      let(:names) { %w[x y] }
      let(:size) { %w[Q 2] }
      it 'generates decl' do
        expect(subject).to match(
          [
            'xss = [None for _ in range(Q)]',
            'yss = [None for _ in range(Q)]',
            'for i in range(Q):',
            '    line = list(map(int, input().split()))',
            '    xss[i] = line[0::2]',
            '    yss[i] = line[1::2]'
          ]
        )
      end
    end
  end

  describe '#generate' do
    subject { generator.generate(pbm) }
    let(:pbm) do
      AtCoderFriends::Problem.new('A') do |pbm|
        pbm.formats_src = formats
        pbm.constants = constants
        pbm.options.interactive = interactive
        pbm.options.binary_values = binary_values
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
          AtCoderFriends::Problem::InputFormat.new(
            :single, :number, %w[N], []
          ),
          AtCoderFriends::Problem::InputFormat.new(
            :varray, :number, %w[x y], %w[N]
          ),
          AtCoderFriends::Problem::InputFormat.new(
            :single, :string, %w[Q], []
          ),
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
      let(:binary_values) { nil }

      it 'generates source' do
        expect(subject).to eq(
          <<~SRC
            # https://atcoder.jp/contests/practice/tasks/practice_1

            MOD = 10**9+7

            N = int(input())
            xs = [None for _ in range(N)]
            ys = [None for _ in range(N)]
            for i in range(N):
                xs[i], ys[i] = list(map(int, input().split()))
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
          AtCoderFriends::Problem::InputFormat.new(
            :single, :number, %w[N Q], []
          )
        ]
      end
      let(:constants) do
        [
          AtCoderFriends::Problem::Constant.new('N', :max, '26'),
          AtCoderFriends::Problem::Constant.new(nil, :mod, '2^32')
        ]
      end
      let(:interactive) { true }
      let(:binary_values) { nil }

      it 'generates source' do
        expect(subject).to eq(
          <<~'SRC'
            # https://atcoder.jp/contests/practice/tasks/practice_2

            MOD = 2**32

            N, Q = list(map(int, input().split()))

            print(ans)
          SRC
        )
      end

      context 'for a binary problem' do
        before do
          allow(pbm).to receive(:url) do
            'https://atcoder.jp/contests/abc006/tasks/abc006_1'
          end
        end
        let(:formats) do
          [
            AtCoderFriends::Problem::InputFormat.new(
              :single, :number, %w[N], []
            )
          ]
        end
        let(:constants) do
          [
            AtCoderFriends::Problem::Constant.new('N', :max, '9')
          ]
        end
        let(:interactive) { false }
        let(:binary_values) { %w[YES NO] }

        it 'generates source' do
          expect(subject).to eq(
            <<~'SRC'
              # https://atcoder.jp/contests/abc006/tasks/abc006_1


              N = int(input())

              print('YES' if cond else 'NO')
            SRC
          )
        end
      end
    end
  end
end
