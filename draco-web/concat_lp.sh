# usage: ./concat_lp.sh srcdir destdir

declare -a files=("define"
"generate"
"hard"
"soft"
"weights"
"assign_weights"
"optimize"
"output"
)

output=""
newline=$'\n\n'

for file in "${files[@]}"
do
  path="${1}/${file}.lp"
  lp=$(cat $path | sed -e s/\`/\'/g)
  output+="export const ${file} = \`${lp}\`;${newline}"
done
echo "$output" > $2/all.ts
