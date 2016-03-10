APPNAME = marathon-alerts
VERSION=0.0.1-dev
TESTFLAGS=-v -cover -covermode=atomic
TEST_COVERAGE_THRESHOLD=48.0

build:
	go build -tags netgo -ldflags "-w" -o ${APPNAME} .

build-linux:
	GOOS=linux GOARCH=amd64 go build -tags netgo -ldflags "-w -s -X main.APP_VERSION=${VERSION}" -v -o ${APPNAME}-linux-amd64 .

build-mac:
	GOOS=darwin GOARCH=amd64 go build -tags netgo -ldflags "-w -s -X main.APP_VERSION=${VERSION}" -v -o ${APPNAME}-darwin-amd64 .

build-all: build-mac build-linux

all: setup
	build
	install

setup:
	go get github.com/wadey/gocovmerge
	glide install

test-only:
	go test ${TESTFLAGS} github.com/ashwanthkumar/marathon-alerts/${name}

test:
	go test ${TESTFLAGS} -coverprofile=main.txt github.com/ashwanthkumar/marathon-alerts/
	go test ${TESTFLAGS} -coverprofile=checks.txt github.com/ashwanthkumar/marathon-alerts/checks

test-ci: test
	gocovmerge main.txt checks.txt > coverage.txt
	@go tool cover -html=coverage.txt -o coverage.html
	@go tool cover -func=coverage.txt | grep "total:" | awk '{print $$3}' | sed -e 's/%//' > coverage.out
	@bash -c 'COVERAGE=$$(cat coverage.out);	\
	echo "Current Coverage % is $$COVERAGE, expected is ${TEST_COVERAGE_THRESHOLD}.";	\
	exit $$(echo $$COVERAGE"<${TEST_COVERAGE_THRESHOLD}" | bc -l)'
