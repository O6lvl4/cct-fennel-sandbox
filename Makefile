build:
	fennel --compile src/main.fnl > dist/main.lua

watch:
	@echo "Watching for changes..."
	@while true; do \
		inotifywait -e modify src/main.fnl 2>/dev/null || sleep 1; \
		make build; \
		echo "Rebuilt main.lua"; \
	done

clean:
	rm -f dist/main.lua

install:
	npm install

.PHONY: build watch clean install