import argparse

parser = argparse.ArgumentParser(prog='./danker.sh', 
        description='Compute PageRank on Wikipedia.',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('wikilang', type=str, help='Wikipedia language edition, e.g. "en".' +
                                               '"ALL" for all languages available in ' +
                                               'the project')
parser.add_argument('-p', '--project', type=str, default='wiki',
                    help='Wiki project, currently supported [wiki, books, source].')
parser.add_argument('-i', '--iterations', type=int, default=40,
                    help='PageRank number of iterations.')
parser.add_argument('-d', '--damping', type=float, default=0.85,
                    help='PageRank damping factor.')
parser.add_argument('-s', '--start', type=float, default=0.1,
                    help='PageRank starting value.')
parser.add_argument('-b', '--bigmem', action='store_true',
                    help='Switch for "big memory" option.')
args = parser.parse_args()
if args.project:
    if args.project != 'wiki':
        print('-p', args.project, end='')
if args.iterations:
    print('', '-i', args.iterations, end='')
if args.damping:
    print('', '-d', args.damping, end='')
if args.start:
    print('', '-s', args.start, end='')
if args.bigmem:
    print('', '-b', end='')
print('', args.wikilang)
