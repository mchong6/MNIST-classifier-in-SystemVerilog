from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import argparse
import sys

import numpy as np
from tensorflow.examples.tutorials.mnist import input_data
import matplotlib.pyplot as plt
import pylab
from scipy import misc


import tensorflow as tf

#indicate if you want to train or evaluate accuracy of truncated weights
train = 0

def main():
  # Import data
  mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

  # Create the model
  train = 0
  x = tf.placeholder(tf.float32, [None, 784])
  if train:
      W = tf.Variable(tf.zeros([784, 10]))
  else:
      W = tf.Variable(np.around(np.loadtxt("test.csv", dtype='float32',delimiter=',')))

  y = (tf.matmul(x, W))
  # Define loss and optimizer
  y_ = tf.placeholder(tf.float32, [None, 10])
  cross_entropy = tf.reduce_mean(
      tf.nn.softmax_cross_entropy_with_logits(labels=y_, logits=y))
  regularize = 0.001 * tf.nn.l2_loss(W)
  train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy+regularize)

  sess = tf.InteractiveSession()
  tf.global_variables_initializer().run()
  # Train
  for _ in range(60000):
    if (train):
        batch_xs, batch_ys = mnist.train.next_batch(100)
        #convert to black-white 
        batch_xs = 1. * (batch_xs > 0.5)
        test_image = batch_xs[0,:].reshape([28,28])
        plt.imshow(test_image)
        pylab.show()
        sess.run([train_step], feed_dict={x: batch_xs, y_: batch_ys})

  # Test trained model
  correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
  accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

  if train:
      np.savetxt("test.csv", (np.around(W.eval() * 1e2, 0)).astype(int), delimiter=',', fmt='%d')
main()
