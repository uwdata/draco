rm draco_runtimes.json

for nfields in 5 10 15 20 25
do
  for nencodings in 1 2 3 4 5
  do
    python time_draco.py ${nfields} ${nencodings}
  done
done
