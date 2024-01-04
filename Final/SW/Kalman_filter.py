import numpy as np
import random
import matplotlib.pyplot as plt
int_num = 9
frac_num = 9
def DecToBin_machine(num,accuracy):
    integer = int(num)
    flo = num - integer
    integercom = '{:02b}'.format(integer)
    tem = flo
    flo_list = []
    for i in range(accuracy):
        tem *= 2
        flo_list += str(int(tem))
        tem -= int(tem)
    flocom = flo_list
    binary_value = integercom + '.' + ''.join(flocom)
    return binary_value

def Decimalwithprecision(n, precision = frac_num):
  neg = 0
  if(n < 0):
    neg = 1
    nm = -n
  else:
    neg = 0
    nm = n

  n_str = str(nm)
  fl = float(DecToBin_machine(nm,accuracy = frac_num))
  #print(fl)
  fl = f'{fl:.9f}'
  #print(fl)
  fl_str = str(fl)
  sp = fl_str.split('.')
  front = float(int(sp[0], 2))
  while(len(sp[1]) < frac_num):
    sp[1] = sp[1] + '0'
  #print(sp[1])
  back = int(sp[1], 2) / 512
  if neg:
    dect = -(front + back)
  else:
    dect = (front + back)
  fl_int, fl_dec = fl_str.split(".")
  while(len(fl_int) < int_num):
    fl_int = '0' + fl_int
  fl_binary = fl_int + fl_dec
  if(neg):
    fl_binary = toTwosComplement(fl_binary)
  return dect, fl_binary

def toTwosComplement(binarySequence):
    convertedSequence = [0] * len(binarySequence)
    carryBit = 1
    # INVERT THE BITS
    for i in range(0, len(binarySequence)):
        if binarySequence[i] == '0':
            convertedSequence[i] = 1
        else:
            convertedSequence[i] = 0

    # ADD BINARY DIGIT 1

    if convertedSequence[-1] == 0: #if last digit is 0, just add the 1 then there's no carry bit so return
            convertedSequence[-1] = 1
            return ''.join(str(x) for x in convertedSequence)

    for bit in range(0, len(binarySequence)):
        if carryBit == 0:
            break
        index = len(binarySequence) - bit - 1
        if convertedSequence[index] == 1:
            convertedSequence[index] = 0
            carryBit = 1
        else:
            convertedSequence[index] = 1
            carryBit = 0

    return ''.join(str(x) for x in convertedSequence)
# Observation 
Z = []
for i in range (1, 101):
  Z.append(i)

# Noise 
noise = np.random.normal(0,1,100)
Zt = Z + noise
# Zt without quantixation
Zt_nq = Z + noise


f_Zt = open("Tt.dat", "w")
for i in range(0, 100):
  Zt[i], Zt_bin = Decimalwithprecision(Zt[i], precision = frac_num)
  f_Zt.write(Zt_bin + '\n')
f_Zt.close()

# Initial status
X = np.array([[0], [0]])
f_X = open("T.dat", "w")
f_X.write('000000000000000000' + '\n')
f_X.write('000000000000000000' + '\n')

# Covariance matrix
P = np.array([[1, 0], [0, 1]])
f_P = open("PT.dat", "w")
f_P.write('000000001000000000' + '\n')
f_P.write('000000000000000000' + '\n')
f_P.write('000000000000000000' + '\n')
f_P.write('000000001000000000' + '\n')

# Transition matrix
F = np.array([[1, 1], [0, 1]])

# Covariance transition matrx
Q = np.array([[1, 0], [0, 1]])

# Obsercation matrix
H = np.array([[1, 0]])

# Observation noise
R = np.array([1])

X_ = np.array([[0], [0]])

pos = []
speed = []
# interation process
for i in range(0, 100):
  X_ = np.dot(F, X)
  X_[0, 0], X_00_bin = Decimalwithprecision(X_[0, 0], precision = frac_num)
  X_[1, 0], X_10_bin = Decimalwithprecision(X_[1, 0], precision = frac_num)

  tmp1 = np.dot(F, P)
  tmp1[0, 0], tmp1_00_bin = Decimalwithprecision(tmp1[0, 0], precision = frac_num)
  tmp1[0, 1], tmp1_01_bin = Decimalwithprecision(tmp1[0, 1], precision = frac_num)
  tmp1[1, 0], tmp1_10_bin = Decimalwithprecision(tmp1[1, 0], precision = frac_num)
  tmp1[1, 1], tmp1_11_bin = Decimalwithprecision(tmp1[1, 1], precision = frac_num)
  Ft = np.transpose(F)
  tmp10 = np.dot(tmp1, Ft)
  tmp10[0, 0], tmp10_00_bin = Decimalwithprecision(tmp10[0, 0], precision = frac_num)
  tmp10[0, 1], tmp10_01_bin = Decimalwithprecision(tmp10[0, 1], precision = frac_num)
  tmp10[1, 0], tmp10_10_bin = Decimalwithprecision(tmp10[1, 0], precision = frac_num)
  tmp10[1, 1], tmp10_11_bin = Decimalwithprecision(tmp10[1, 1], precision = frac_num)
  P_ = tmp10 + Q 

  tmp2 = np.dot(H, P_)
  tmp2[0, 0], tmp2_00_bin = Decimalwithprecision(tmp2[0, 0], precision = frac_num)
  tmp2[0, 1], tmp2_01_bin = Decimalwithprecision(tmp2[0, 1], precision = frac_num)                  
  Ht = np.transpose(H)
  tmp3 = np.dot(tmp2, Ht)
  tmp3[0, 0], tmp3_00_bin = Decimalwithprecision(tmp3[0, 0], precision = frac_num)
  tmp60 = tmp3 + R
  tmp70 = np.dot(P_, Ht)
  tmp70[0, 0], tmp70_00_bin = Decimalwithprecision(tmp70[0, 0], precision = frac_num)
  tmp70[1, 0], tmp70_00_bin = Decimalwithprecision(tmp70[1, 0], precision = frac_num)
  K = tmp70/ tmp60
  K[0, 0], K_00_bin = Decimalwithprecision(K[0, 0], precision = frac_num)
  K[1, 0], K_10_bin = Decimalwithprecision(K[1, 0], precision = frac_num)
  tmp20 = np.dot(H, X_)
  tmp20[0, 0], tmp20_bin = Decimalwithprecision(tmp20[0, 0], precision = frac_num)
  tmp4 = Zt[i] - tmp20
  tmp30 = np.dot(K, tmp4)
  tmp30[0, 0], tmp30_00_bin = Decimalwithprecision(tmp30[0, 0], precision = frac_num)
  tmp30[1, 0], tmp30_10_bin = Decimalwithprecision(tmp30[1, 0], precision = frac_num)
  X = X_ + tmp30
  X[0, 0], X_00_bin = Decimalwithprecision(X[0, 0], precision = frac_num)
  X[1, 0], X_10_bin = Decimalwithprecision(X[1, 0], precision = frac_num)
  f_X.write(X_00_bin + '\n')
  f_X.write(X_10_bin + '\n')

  tmp5 = np.dot(K, H)
  tmp5[0, 0], tmp5_00_bin = Decimalwithprecision(tmp5[0, 0], precision = frac_num)
  tmp5[0, 1], tmp5_01_bin = Decimalwithprecision(tmp5[0, 1], precision = frac_num)
  tmp5[1, 0], tmp5_10_bin = Decimalwithprecision(tmp5[1, 0], precision = frac_num)
  tmp5[1, 1], tmp5_11_bin = Decimalwithprecision(tmp5[1, 1], precision = frac_num)
  tmp6 = np.array([[1, 0], [0, 1]]) - tmp5
  P = np.dot(tmp6, P_)
  P[0, 0], P_00_bin = Decimalwithprecision(P[0, 0], precision = frac_num)
  P[0, 1], P_01_bin = Decimalwithprecision(P[0, 1], precision = frac_num)
  P[1, 0], P_10_bin = Decimalwithprecision(P[1, 0], precision = frac_num)
  P[1, 1], P_11_bin = Decimalwithprecision(P[1, 1], precision = frac_num)
  f_P.write(P_00_bin + '\n')
  f_P.write(P_01_bin + '\n')
  f_P.write(P_10_bin + '\n')
  f_P.write(P_11_bin + '\n')

  current_pos = X[0, 0]
  current_speed = X[1, 0]
  pos.append(current_pos)
  speed.append(current_speed)

f_X.close()
f_P.close()

# Iteration without quantization

# Initial status
X_nq = np.array([[0], [0]])

# Covariance matrix
P_nq = np.array([[1, 0], [0, 1]])

# Transition matrix
F_nq = np.array([[1, 1], [0, 1]])

# Covariance transition matrx
Q_nq = np.array([[1, 0], [0, 1]])

# Obsercation matrix
H_nq = np.array([[1, 0]])

# Observation noise
R_nq = np.array([1])

pos_nq = []
speed_nq = []
# interation process
for i in range(0, 100):

  X__nq = np.dot(F_nq, X_nq)

  tmp1_nq = np.dot(F_nq, P_nq)
  Ft_nq = np.transpose(F_nq)
  P__nq = np.dot(tmp1_nq, Ft_nq) + Q_nq 
  tmp2_nq = np.dot(H_nq, P__nq)
  Ht_nq = np.transpose(H_nq)
  tmp3_nq = np.dot(tmp2_nq, Ht_nq) + R_nq
  K_nq = np.dot(P__nq, Ht_nq) / tmp3_nq

  tmp4_nq = Zt_nq[i] - np.dot(H_nq, X__nq)
  X_nq = X__nq + np.dot(K_nq, tmp4_nq)

  tmp5_nq = np.dot(K_nq, H_nq)
  tmp6_nq = np.array([[1, 0], [0, 1]]) - np.dot(K_nq, H_nq)
  P_nq = np.dot(tmp6_nq, P__nq)
  
  current_pos_nq = X_nq[0, 0]
  current_speed_nq = X_nq[1, 0]
  pos_nq.append(current_pos_nq)
  speed_nq.append(current_speed_nq)

error_pos = []
for i in range(0, 100):
  error_pos.append(pos_nq[i] - pos[i])

plt.plot(Z, error_pos)
plt.title("Quantization Error") # title
plt.ylabel("Error") # y label
plt.xlabel("time") # x label
plt.ylim(-0.01, 0.01) # ³]©w y ¶b®y¼Ð½d³ò
plt.show()