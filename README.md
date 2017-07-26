# MNIST-classifier-in-SystemVerilog

Implementation of a simple 2 layer Neural network to classify a digit. Weights are truncated to integers for easy multiplication in hardware.

Hardware used:
Altera Cyclone IV FPGA
Terasic 1.3 Mega Pixel Camera

Network:
Input layer of dimension [1,784] and output layer of dimension [784, 10]. Matrix multiplication done on FPGA is done in pixel-wise manner. 640 x 480 Camera image is truncated and downsampled to 28x28, which is the same dimension as an MNIST image.

Instructions:

First run tf.py to train the neural network and obtain truncated weights. Run weights_to_hex.py to convert weights to hexadecimal which is read in by the FPGA. Place the weights file in the Neural Network folder in SV_code.

Import the project in SV_code to QUARTUS and compile.

Forward Propagation
1) Ensure SW[17] is low on the FPGA
2) Press KEY[0] to reset
3) Press KEY[3] to run
4) Key[3] also toggles between RGB/Greyscale/B/W mode on the screen (VGA output)
5) Center the digit on screen and look at the classification on the HEX display
6) Press KEY[2] to freeze the screen.

Backward Propagation
1) Set SW[16:13] to the correct label in binary. eg) 1000 is label 8.
2) Set SW[17] to high for as long as you want to train.
