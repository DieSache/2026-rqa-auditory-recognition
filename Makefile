MATLAB ?= matlab
TYPST ?= typst
WB_COMMAND ?= wb_command

.PHONY: check analysis manuscript all

check:
	@while IFS= read -r path; do test -z "$$path" || ls -d $$path >/dev/null 2>&1 || { echo "Missing $$path"; exit 1; }; done < required-inputs.txt

analysis: check
	WB_COMMAND="$(WB_COMMAND)" $(MATLAB) -batch "addpath('analysis'); run_analysis"

manuscript:
	$(TYPST) compile main.typ

all: analysis manuscript
