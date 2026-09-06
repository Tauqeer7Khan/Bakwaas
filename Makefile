.PHONY: install warmup version health clean

install:
	./install.sh

warmup:
	venv/bin/python warmup.py

version:
	venv/bin/python bakwaas.py --version

health:
	venv/bin/python bakwaas.py --health

clean:
	rm -f *.wav task-*.log .stop_bakwaas
	rm -rf __pycache__
