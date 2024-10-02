clean:
	@rm -rf package
	@rm -rf components/DevCycle/DevCycle.brs


zip:
	zip -r app.zip . -x "*.DS_Store" -x "node_modules/*" -x "yarn.lock" -x "package-lock.json" -x "*.zip" -x "*.sh" -x ".git*" -x "out/*" -x "package*" -x "out/*" -x "test-app/*" -x "test-app.zip" -x "tests/*"
	@cd test-app && zip -r ../test-app.zip . && cd ..

VERSION := $(if $(VERSION),$(VERSION),0.0.0)

bundle:
	@touch components/DevCycle/DevCycle.brs
	@find components/DevCycle -name "*.brs" | grep -vE "Task|DevCycle\.brs" | xargs cat > components/DevCycle/DevCycle.brs
	@rm -rf package package.zip && mkdir -p package
	@cp -r components/DevCycle/DevCycle.brs package/DevCycle.brs
	@cp -r components/DevCycle/DevCycleTask.brs package/DevCycleTask.brs
	@cp -r components/DevCycle/DevCycleTask.xml package/DevCycleTask.xml
	@if [ "$(shell uname)" = "Darwin" ]; then \
		sed -i '' '\
		/uri="pkg:\/components\/DevCycle\/DevCycleSGClient.brs"/d; \
		/uri="pkg:\/components\/DevCycle\/DevCycleUser.brs"/d; \
		/uri="pkg:\/components\/DevCycle\/DevCycleOptions.brs"/d; \
		s/uri="pkg:\/components\/DevCycle\/DevCycleClient.brs"/uri="pkg:\/components\/DevCycle\/DevCycle.brs"/; \
		' package/DevCycleTask.xml; \
	else \
		sed -i '\
		/uri="pkg:\/components\/DevCycle\/DevCycleSGClient.brs"/d; \
		/uri="pkg:\/components\/DevCycle\/DevCycleUser.brs"/d; \
		/uri="pkg:\/components\/DevCycle\/DevCycleOptions.brs"/d; \
		s/uri="pkg:\/components\/DevCycle\/DevCycleClient.brs"/uri="pkg:\/components\/DevCycle\/DevCycle.brs"/; \
		' package/DevCycleTask.xml; \
	fi
	@zip -r package-$(VERSION).zip package
	
test-app: bundle
	@cp package/DevCycle.brs test-app/components/DevCycle/DevCycle.brs
	@cp package/DevCycleTask.brs test-app/components/DevCycle/DevCycleTask.brs
	@cp package/DevCycleTask.xml test-app/components/DevCycle/DevCycleTask.xml
	@cd test-app && zip -r ../test-app.zip . && cd ..
	@cp test-app.zip tests/sample/channel.zip

app: clean zip