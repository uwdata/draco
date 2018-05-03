# usage: ./concat_lp.sh srcdir destdir

all=$(cat $1/define.lp $1/generate.lp $1/hard.lp $1/soft.lp $1/weights.lp $1/assign_weights.lp $1/optimize.lp $1/output.lp | sed -e s/\`/\'/g)

echo "export const constraints: string = \`${all}\`;" > $2/all.ts
