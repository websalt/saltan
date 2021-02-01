# Compile the command-line version
saltan:
	nimble build -d:ssl

release:
	nimble build -d:release -d:ssl

# Maximum speed
# Maximum risk
danger:
	nimble build -d:danger --passc:-flto
