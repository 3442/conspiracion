# Lord of the rings: MESI & cache coherence

##### Fabián Montero, Alejandro Soto, Julián Camacho


### Introduction
This is a quad-core soft processor that implements ARMv4 with 64kb cache in each core with no shared cache. It is implemented in a DE-SoC-1 Altera FPGA.

In order to make ARMv4 capable of multicore, ldrex and strexeq were also implemented.


### Getting started
There are two main components in this project. The soft core and software tests and simulations that simulate and can be executed in it.


#### Prerequisites
- An SD card flashed with a Terasic image for the DE-SoC-1 Altera FPGA available at: https://www.terasic.com.tw/en/
- Nix package manager version > 2.4 with flakes enabled. All other requirements will be installed by Nix. In order to initiate this process, ```cd``` into the root of the project and run the following command:

    nix develop


#### Building and loading the bitstream
In order to build the soft core, run quartus:

    quartus

and open the ```conspiracion.qpf``` project file.

Once the project is loaded, open Platform Designer and ```Generate HDL```. Close Platform Designer and ```Compile Design```, this may take up to 40 mins.

Now click File->Generate Programming Files and use the following settings:
- Type: Raw Binary File (.rbf)
- Mode: Passive Parallel x16
- Change ```output_file.rbf``` to ```output_files/conspiracion.rbf```
- In the ```Input files to convrert``` section, click ```Page_0``` -> Add files -> ```Output_files/conspiracion.sof```
- Click ```Generate```

In your terminal, run ```nix develop``` if you hadn't already and run:

    make demo.bin

Notice the printed path.

Plug in your SD card and mount it's ```/boot``` partition and create a directory called ```taller``` inside it. Copy the contents of the printed path into this directory, renaming it to boot.bin:

    cp </printed/path> </path/to/mounted/boot/dir>/taller/boot.bin

Copy the output_files/conspiracion.rbf into taller:

    cp </path/to/the/project/output_files/conspiracion.rbf> </path/to/mounted/boot/dir>/taller/

Unmount your SD card and plug it into the FPGA.

In order to boot:
- Turn off the reset switch
- In your terminal, run: ```kermit hps-fpga.kermit```
- Power the FPGA on
- Wait for uBoot and Linux to boot
- In another terminal, run ```scrripts/jtag_uart.sh```
- Turn on the reset switch

Done! :)