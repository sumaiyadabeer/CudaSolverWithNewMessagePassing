# nvcc -g -G src/Lsolve.cu src/b_function.cu src/communication.cu src/eta_function.cu src/helper.cu src/calculate_error.cu -std=c++11

CC := nvcc 
SDIR := src
ODIR := obj
CFLAGS :=  -std=c++11 -prec-div=true # -G: device-debug -g host-debug -lineinfo for gdblinetrack -lcublas -arch=sm_70



main: obj/Lsolve.o obj/b_function.o  obj/calculate_error.o obj/communication.o obj/eta_function.o obj/helper.o
	$(CC) $(CFLAGS) obj/Lsolve.o obj/b_function.o  obj/calculate_error.o obj/communication.o obj/eta_function.o obj/helper.o -o main
	


#change this to wildcard
obj/Lsolve.o: src/Lsolve.cu
	$(CC) -c src/Lsolve.cu -o obj/Lsolve.o 

obj/b_function.o: src/b_function.cu
	$(CC) -c src/b_function.cu -o obj/b_function.o 


obj/communication.o: src/communication.cu
	$(CC) -c src/communication.cu -o obj/communication.o 


obj/eta_function.o: src/eta_function.cu
	$(CC) -c src/eta_function.cu -o obj/eta_function.o 


obj/helper.o: src/helper.cu
	$(CC) -c src/helper.cu -o obj/helper.o 


obj/calculate_error.o: src/calculate_error.cu
	$(CC) -c src/calculate_error.cu -o obj/calculate_error.o 



clean:
	rm -f $(ODIR)/*.o Lsolve



