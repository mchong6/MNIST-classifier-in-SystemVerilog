import numpy as np
import tensorflow as tf
from scipy import ndimage
from scipy import misc

x = tf.placeholder(tf.float32, shape = None)
w = tf.placeholder(tf.float32, shape = None)
y = tf.matmul(x, w)
prediction = tf.argmax(y,1)

init = tf.global_variables_initializer()
with tf.Session() as sess:
    sess.run(init)
    w1 = np.loadtxt('weights.csv', dtype='float32', delimiter=',')
    #z = np.fromfile('temp.png')
    # z = misc.imread('temp.png').reshape([1, 784])
    # z =  1. * (z > 200)
    pred, output = sess.run([prediction, y], feed_dict={x: np.ones([1, 784]), w:w1})
    print output
    print pred
    one_hot = np.zeros([1,10])
    one_hot[0,0] = 1000
    error = output - one_hot
    delta = 1e-3 * np.ones([784,1]).dot(error)
    print delta[783,:]
    np.savetxt('new_weights.csv', w1-delta, delimiter=',', fmt='%d')
    pred, output = sess.run([prediction, y], feed_dict={x: np.ones([1, 784]), w:(w1-delta)})
    print pred
