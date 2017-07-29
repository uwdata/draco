test:
	pytest

asp-mac:
	bin/clingcon-mac asp/vega-lite.lp asp/task.lp

asp-linux:
	bin/clingcon-linux asp/vega-lite.lp asp/task.lp

foo.vl.json:
	python3 main.py > foo.vl.json

foo.png: foo.vl.json
	npm run run --silent -- foo.vl.json > foo.png

.PHONY : clean
clean:
	rm -f foo.vl.json foo.png
