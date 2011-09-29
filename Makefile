
.PHONY: all
all: main

SRCS = main.d fft.d plotting.d
HIDE:=@

.PHONY: clean
clean:
	$(HIDE) rm -f *.o
	$(HIDE) rm -f main

main: $(SRCS)
	$(HIDE) dmd -of$* $(SRCS)