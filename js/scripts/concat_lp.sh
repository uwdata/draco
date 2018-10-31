# usage: ./concat_lp.sh srcdir destdir

declare -a files=("topk-lua"
"define"
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
  const=$(echo $file | tr a-z A-Z | tr \- _)
  output+="export const ${const}: string = \`${lp}\`;${newline}"
done

echo "$output" > $2/constraints.ts
