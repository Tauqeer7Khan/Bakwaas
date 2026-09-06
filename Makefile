.PHONY: install warmup version health health-check clean

install:
	./install.sh

warmup:
	venv/bin/python warmup.py

version:
	venv/bin/python bakwaas.py --version

health:
	venv/bin/python bakwaas.py --health

health-check:
	venv/bin/python scripts/check_health.py

clean:
	rm -f *.wav task-*.log .stop_bakwaas
	rm -rf __pycache__
