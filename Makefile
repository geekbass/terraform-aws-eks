check-env:
ifeq ($(BRANCH),)
  	$(error Please set a BRANCH when calling make. Example "make update master")
endif

update: check-env
	@echo Updating submodule...
	@git submodule init && git submodule update
	@echo Updating Submodule to using branch $(BRANCH)...
	@cd stage/ && \
		git pull origin $(BRANCH)
	@cd ../ 
	@cp -acp stage/eks/* ./
	@echo Please commit your changes and release new version...
