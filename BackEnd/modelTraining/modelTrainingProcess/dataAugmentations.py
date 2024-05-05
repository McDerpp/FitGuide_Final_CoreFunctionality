import tensorflow as tf
from tensorflow.keras.models import Sequential,load_model
from tensorflow.keras.layers import LSTM, Dense, Bidirectional, BatchNormalization
from tensorflow.keras.callbacks import TensorBoard,ReduceLROnPlateau, EarlyStopping, ModelCheckpoint,Callback
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.regularizers import l1, l2
import numpy as np
import copy
import matplotlib.pyplot as plt
from imblearn.over_sampling import SMOTE
from tqdm import tqdm
import numpy as np
from sklearn.model_selection import train_test_split

# from tensorflow_model_optimization.quantization.keras import quantize_model
from collections import Counter
import random as rand
import os


# [CURRENTLY BEING USED]
# This function converts txt file into variable that can be use (^^^^refer above for how txt file are arranged and converted)
# PARAMETERS:
# txt_file -> txt file location
# label( 0 or 1 ) -> this is for classification ( if the txt file contains the correct executions then assign it as 1 and wrong as 0)
# Simplify(True or False) -> this determines whether to simplify the coordinates value by taking away certain amount of decimal places
# simplify_level -> this determines the amount of decimal places to remove
def txt_pre_process(txt_file,label,simplify=False,simplify_level=14 ):
    label_array = []
    temp_feature_data = []
    temp_sequence_data = []
    batch_data = []

    with open(str(txt_file), 'r') as file:

        for line in file:
            values = line.strip().split('|')

            temp_feature_data = []

            for value in values:
                float_value = str(value)

                #FIRST PART OF THE SEQUENCE
                if float_value == 'START':
                    temp_sequence_data=[]

                elif float_value == 'END':
                    batch_data.append(temp_sequence_data)
                    label_array.append(label)


                elif float_value != '' and float_value != 'START':
                    if simplify:
                        float_value = round(float(value),simplify_level)
                    else:
                        float_value = float(value)
                    temp_feature_data.append(float_value)

            if temp_feature_data!=[]:
                temp_sequence_data.append(temp_feature_data)

    label_array = np.array(label_array)
    return [batch_data,label_array]




def translateCollectedDatatoTxt(dataCollected, filePath):
    file = open(filePath, 'w')
    for exerciseSet in dataCollected:
        file.write('START\n')
        for sequence in exerciseSet:
            for individualCoordinate in sequence:
                if len(str(individualCoordinate)) > 10:
                    file.write(f'{str(individualCoordinate)[:10]}|')
                else:
                    file.write(f'{str(individualCoordinate)}|')
            file.write('\n')
        file.write('END\n')

    file.close()







# This function puts a dummy sequences at the end to satisfy the amount of sequences needed for the model or to convert the sequence count uniformly
# pre_processed_input -> this parameters is for the data input
# optional_maxLength -> by assigning a value here we can specify the amount of sequence length
def padding(pre_processed_input,optional_maxLength=0):
    padded_sequences = []
    if optional_maxLength != 0:
        max_length = optional_maxLength
    else:
        max_length = max(len(sequence) for sequence in pre_processed_input)

    for sequence in pre_processed_input:
        padding_length = max_length - len(sequence)
        if padding_length >= 0:
            padded_sequence = np.pad(sequence, ((0, padding_length), (0, 0)), mode='constant')

        else:
            padded_sequence = sequence[:max_length]
        padded_sequences.append(padded_sequence)
    padded_sequences = np.array(padded_sequences)

    return padded_sequences

# [CURRENTLY BEING USED]
# This function combines sets of executions in a randomized order
# base_input -> executions data input
# base_label -> label of executions data input
# concat_input -> 2nd set of executions data input
# concat_label -> 2nd set of label of executions data input
def concatenate_randomize_batches(base_input,base_label,concat_input,concat_label):
    combined_inputs = np.concatenate((base_input,concat_input), axis = 0)
    combined_label = np.concatenate((base_label,concat_label), axis = 0)
    indices = np.random.permutation(len(combined_inputs))
    randomized_inputs = combined_inputs[indices]
    randomized_label = combined_label[indices]
    return [randomized_inputs,randomized_label]




def tally_sequence(sequence_array):
    tally_number = []
    tally_ctr = []

    for x in sequence_array:
        temp = len(x)
        if temp not in tally_number:
            tally_number.append(temp)
            tally_ctr.append(1)
        else:
            for y in range(len(tally_number)) :
                if temp == tally_number[y]:
                    tally_ctr[y] = tally_ctr[y] + 1

    tally_max = 0
    tally_number_arranged = []
    tally_ctr_arranged = []

    for x in range(len(tally_number)):
        # print(len(tally_ctr))
        tally_max = max(tally_ctr)
        for y in range(len(tally_number)):
            if tally_ctr[y] == tally_max:
                tally_number_arranged.append(tally_number[y])
                tally_ctr_arranged.append(tally_ctr[y])
                tally_ctr.pop(y)
                tally_number.pop(y)
                break

    total_ctr = 0
    for x in tally_ctr:
        total_ctr = total_ctr + x


    for x in range(len(tally_number_arranged)):
        print(tally_number_arranged[x],'-->',tally_ctr_arranged[x])

# [CURRENTLY BEING USED]
# this function is an outlier detection for sequence length by going through every executions and checking the length of sequence
# sequences_array -> data input(NOTE!: data input that have not used the padding function)
# threshold -> this determines the minimum frequency of the sequence length
def common_length_sequence(sequences_array,threshold = 5):
    temp = []

    data = [len(seq) for seq in sequences_array]
    data_frequency = Counter(data)
    most_common_data = data_frequency.most_common()
    outlier_frequencies = [value for value, freq in data_frequency.items() if freq < threshold]
    most_common_values = [value for value, freq in most_common_data if freq >= threshold]

    print("Most Common Data Points:", most_common_values)
    print("Outlier Frequencies:", outlier_frequencies)

    for x in sequences_array:
        if len(x) in most_common_values:
            temp.append(x)
    print('-------------------applied frequency outlier detection-------------------')
    print("original num -> ", len(sequences_array))
    print("current num -> ", len(temp))
    print("removed num -> ", len(sequences_array) - len(temp))
    return temp

# [CURRENTLY BEING USED]
# This function is an outlier detection for z-score and as seuqnce length as basis
# sequences_array -> executions data input
# z_score_threshold -> determines the minimum amount of Z-score
def apply_z_score(sequences_array,z_score_threshold = 1):
    data_points = []
    included_datapoints = []
    updated_sequences =[]

    for x in sequences_array:
        temp = len(x)
        if temp not in data_points:
            data_points.append(temp)

    data = np.array(data_points)
    mean_value = np.mean(data)
    standard_deviation = np.std(data)
    z_scores = (data - mean_value) / standard_deviation
    for x in range(len(z_scores)):
        if np.abs(z_scores[x]) <= z_score_threshold:
            included_datapoints.append(data[x])


    for x in sequences_array:
        if len(x) in included_datapoints:
            updated_sequences.append(x)
    print('-------------------applied z-score outlier detection-------------------')
    print("datapoints included -> ", included_datapoints)
    print("original num -> ", len(sequences_array))
    print("current num -> ", len(updated_sequences))
    print("removed num -> ", len(sequences_array) - len(updated_sequences))

    return updated_sequences

# [CURRENTLY BEING USED]
# this function is an outlier detection for sequence length by going through every executions and checking the length of sequence
# sequences_array -> data input(NOTE!: data input that have not used the padding function)
# threshold -> this determines the minimum frequency of the sequence length
def paddingV2(sequences_array_input,optional_maxlength = 0):
    sequences_array = copy.deepcopy(sequences_array_input)


    output = []
    max_length = 0
    if optional_maxlength == 0:
        max_length = max(len(sequence) for sequence in sequences_array)
        expanded_max_length = int(max_length+ ((max_length) * .10))
    else:
        expanded_max_length = optional_maxlength

    # sequence = np.array(sequences_array)


    padding_length_before = 0
    padding_length_after = 0

    for seq in sequences_array:
        # print(seq)
        for x in range(expanded_max_length-len(seq)+1):
            padding_length_before = x
            padding_length_after = expanded_max_length - len(seq) - x
            padded_sequence = np.pad(seq, ((padding_length_before, padding_length_after),(0,0)), mode='constant')
            output.append(padded_sequence)

            # print(padded_sequence)
    print('------------------------applied paddingV2------------------------')
    print('max_length -> ', max_length)
    print('expanded_max_length -> ', expanded_max_length)
    print('original num set of sequences -> ', len(sequences_array))
    print('final num set of sequences -> ', len(output))

    output = np.array(output)
    return output


# [CURRENTLY BEING USED]
# This function converts tf models into tflite models and save then saves it.
# tf_model -> tf model input
# input_shape -> specifies the input shape of the data input for the model(need to review on this one)
# test_dataset -> sets of executions input
# name -> name of the tflite model when saved
# id_number -> randomized id number
# validation_loss -> validation loss value of the model
# validation_accuracy -> validation accuracy value of the model
def convert_tf_to_tflite(tf_model,input_shape,test_dataset,name,id_number,validation_loss,validation_accuracy):
  model = tf.keras.models.load_model(tf_model)

  run_model = tf.function(lambda x: model(x))
  # This is important, let's fix the input size.
  BATCH_SIZE = input_shape[0]
  STEPS = input_shape[1]
  INPUT_SIZE = input_shape[2]
  concrete_func = run_model.get_concrete_function(
      tf.TensorSpec([BATCH_SIZE, STEPS, INPUT_SIZE], model.inputs[0].dtype))

  # model directory.
  MODEL_DIR = "keras_lstm"
  model.save(MODEL_DIR, save_format="tf", signatures=concrete_func)

  converter = tf.lite.TFLiteConverter.from_saved_model(MODEL_DIR)
  tflite_model = converter.convert()


  # Run the model with TensorFlow to get expected results.
  TEST_CASES = 10

  # Run the model with TensorFlow Lite
  interpreter = tf.lite.Interpreter(model_content=tflite_model)
  interpreter.allocate_tensors()
  input_details = interpreter.get_input_details()
  output_details = interpreter.get_output_details()

  for i in range(TEST_CASES):
    expected = model.predict(test_dataset[i:i+1])
    interpreter.set_tensor(input_details[0]["index"], test_dataset[i:i+1, :, :])
    interpreter.invoke()
    result = interpreter.get_tensor(output_details[0]["index"])

    # Assert if the result of TFLite model is consistent with the TF model.
    np.testing.assert_almost_equal(expected, result, decimal=5)
    print("Done. The result of TensorFlow matches the result of TensorFlow Lite.")

    interpreter.reset_all_variables()


  folder_path = "D:/CLARK/Documents/fitguidef/BackEnd/assets/models/TFLiteModels"
  temp = 'converted_model_'

  temp3 = temp + str(name) + id_number + "(loss_"+ str(round(validation_loss,3)) +")" + "(acc_"+  str(round(validation_accuracy,3 )) + ")" + '.tflite'
  final_path = folder_path + temp3
  print("path is -->",final_path )
  # Save the TFLite model to a file
  with open(final_path, "wb") as f:
    f.write(tflite_model)


  return final_path
  # with open("converted_model.tflite", "wb") as f:
  #     f.write(tflite_model)

# [CURRENTLY BEING USED]   -> needs to be reviewed whether its impact is useful or not
# this function augments data that has 0 input, that was replaced when augmented by other functions into random inputs instead
# correct_data_input -> sets of correct executions
# noise_data_input -> sets of incorrect executions
def populate_0_input(correct_data_input,noise_data_input):
    correct_data = copy.deepcopy(correct_data_input)
    noise_data = copy.deepcopy(noise_data_input)

    print(len(correct_data))
    index = 10
    temp = []
    temp_compilation = []
    ctr = 0
    rand_modifier =0

    for set_sequence in tqdm(correct_data, desc="populate_0_input", leave=True):
        rand_modifier = rand.randint(0,len(noise_data))

        for x in range(len(set_sequence)):
            ctr = ctr + 1
            if set_sequence[x][0] == 0:
                temp.append(noise_data[rand_modifier-1][rand.randint(0,len(noise_data[rand_modifier-1])-1)])

            else:
                temp.append(set_sequence[x])

        temp_compilation.append(temp)
        temp =[]


    return temp_compilation


#[NOT IN USE]
class CustomEarlyStopping(Callback):
  def __init__(self, accuracy_threshold=0.95, loss_threshold=0.10):
      super(CustomEarlyStopping, self).__init__()
      self.accuracy_threshold = accuracy_threshold
      self.loss_threshold = loss_threshold

  def on_epoch_end(self, epoch, logs=None):
      if logs is None:
          logs = {}

      if logs.get('val_accuracy') is None or logs.get('val_loss') is None:
          return

      if logs.get('val_accuracy') >= self.accuracy_threshold and logs.get('val_loss') <= self.loss_threshold:
          self.model.stop_training = True
          print(f"\nTraining stopped as validation accuracy reached {logs.get('val_accuracy'):.4f} "
                f"and validation loss reached {logs.get('val_loss'):.4f}")

#[NOT IN USE]
class CustomEarlyStoppingV2(Callback):
    def __init__(self, accuracy_threshold=0.95, loss_threshold=0.10, patience=None):
        super(CustomEarlyStopping, self).__init__()
        self.accuracy_threshold = accuracy_threshold
        self.loss_threshold = loss_threshold
        self.patience = patience
        self.wait = 0  # Counter for patience

    def on_epoch_end(self, epoch, logs=None):
        if logs is None:
            logs = {}

        if logs.get('val_accuracy') is None or logs.get('val_loss') is None:
            return

        if logs.get('val_accuracy') >= self.accuracy_threshold and logs.get('val_loss') <= self.loss_threshold:
            self.model.stop_training = True
            print(f"\nTraining stopped as validation accuracy reached {logs.get('val_accuracy'):.4f} "
                  f"and validation loss reached {logs.get('val_loss'):.4f}")
        else:
            if self.patience is not None and self.patience > 0:
                current_val_loss = logs.get('val_loss')
                if current_val_loss is not None:
                    if current_val_loss < self.best:
                        self.best = current_val_loss
                        self.wait = 0
                    else:
                        self.wait += 1
                        if self.wait >= self.patience:
                            self.model.stop_training = True
                            print(f"\nTraining stopped due to lack of improvement for {self.patience} epochs.")
                            self.restore_best_weights()

# [NOT IN USE]
# this function augments the coordinates of individual sequence by randomly choosing it then assigning it with another value from noise input
# sequence_array_list_input -> sets of correct executions
# noise_sequence_list_input -> sets of incorrect executions
# num_data_aug -> number of sequence to augment
# num_aug_in_1_seq -> number of coordinates in 1 sequence to augment
# noise_seq_len -> range of expansion??? (not sure about this)
def data_aug_sensitivity(sequence_array_list_input,noise_sequence_list_input,num_data_aug = 3,num_aug_in_1_seq = 3,noise_seq_len = 2):
  sequence_array_list = copy.deepcopy(sequence_array_list_input)
  noise_sequence_list = copy.deepcopy(noise_sequence_list_input)

  compile = []
  temp_seq = []
  temp_storage = []
  temp_rand = []
  num = 0
  ctr1111 = 0
  temp_rand2 = 0
  temp_rand3 = 0

# per sequences
  for sequence in tqdm(sequence_array_list, desc="data_aug_seq_sensitivity", leave=True):
    # loops for the number of data augmentation per sequence
    for ctr in range(num_data_aug):
      # loops for the amount of number of augmentation in the sequence(loops to get random index)
      while len(temp_rand)!=num_aug_in_1_seq:
        num = rand.randint(0,len(sequence)-1)
        if num in temp_rand:
          continue
        else:
          temp_rand.append(num)

      #actual augmentation of the sequence
      temp_seq = sequence.copy()
      # store in a temp variable and to be edited

      # number of augmentation to be done in a sequence
      for ctr1 in range(len(temp_rand)):

        # number of sequence to be expanded(index + number of noise_seq_len)
        for ctr2 in range(noise_seq_len):
          temp_rand2 = rand.randint(0,len(noise_sequence_list)-1)
          temp_rand3 = rand.randint(0,len(noise_sequence_list[0])-1)

          if (temp_rand[ctr1] + ctr2) < len(temp_seq):
            temp_seq[temp_rand[ctr1] + ctr2] = noise_sequence_list[temp_rand2][temp_rand3]

          else:
            continue

      # for test1 in sequence
      compile.append(temp_seq)
      temp_seq = []
      temp_rand = []


  return compile

# [NOT IN USE]
def data_aug_seq_sensitivity(sequence_array_list_input,num_to_aug=2,num_coor_edit=3,num_sequence_edit=2):
  sequence_array_list = copy.deepcopy(sequence_array_list_input)

  compile = []
  temp = []
  rand_coor = []


  for ctr in tqdm(range(num_to_aug), desc="data_aug_coor_sensitivity", leave=True):
    for sequence in sequence_array_list:
      for ctr3 in range(num_sequence_edit):
        what_sequence = rand.randint(0,len(sequence)-1)
        for ctr2 in range(num_coor_edit):
          what_coor = rand.randint(0,len(sequence[0])-1)
          rand_coor = rand.randint(0,9999999999)
          rand_coor = rand_coor / (10 ** len(str(rand_coor)))
          print(sequence[what_sequence][what_coor],'---',rand_coor)
          sequence[what_sequence][what_coor]=rand_coor
      compile.append(sequence)
  return compile

# [NOT IN USE]
def data_aug_coor_sensitivity(sequence_array_list_input,num_coor_edit=45,num_sequence_edit=8):
  sequence_array_list = copy.deepcopy(sequence_array_list_input)

  compile = []
  temp = []
  rand_coor = []
  temp_seq = []



  # for ctr in tqdm(range(num_to_aug), desc="data_aug_coor_sensitivity", leave=True):
  for sequence in sequence_array_list:
    print('------------------------------------------------------------------------')
    # print(len(sequence))
    temp_seq = sequence.copy()
    for ctr3 in range(num_sequence_edit):
      what_sequence = rand.randint(0,len(sequence)-1)
      num_coor_edit = rand.randint(int(num_coor_edit*.65),num_coor_edit)
      print("----")

      for ctr2 in range(num_coor_edit):
        what_coor = rand.randint(0,len(sequence[0])-1)
        # rand_coor = rand.randint(0,9999999999)
        rand_coor = rand.randint(0,999)
        rand_coor = rand_coor / (10 ** len(str(rand_coor)))
        # print(temp_seq[what_sequence][what_coor],'---',rand_coor)
        temp_seq[what_sequence][what_coor]=rand_coor
    compile.append(sequence)
  return compile




# [NOT IN USE]
def plot_training_history(history):
    epochs = range(1, len(history.history['loss']) + 1)

    # Plotting training and validation loss
    plt.figure(figsize=(12, 6))
    plt.subplot(1, 2, 1)
    plt.plot(epochs, history.history['loss'], label='Training Loss')
    plt.plot(epochs, history.history['val_loss'], label='Validation Loss')
    plt.title('Training and Validation Loss')
    plt.xlabel('Epochs')
    plt.ylabel('Loss')
    plt.legend()

    # Plotting training and validation accuracy
    plt.subplot(1, 2, 2)
    plt.plot(epochs, history.history['accuracy'], label='Training Accuracy')
    plt.plot(epochs, history.history['val_accuracy'], label='Validation Accuracy')
    plt.title('Training and Validation Accuracy')
    plt.xlabel('Epochs')
    plt.ylabel('Accuracy')
    plt.legend()

    plt.tight_layout()
    plt.show()

# this function augments the coordinates by assigning a value within a certain range
# sequence_array_list_input
# num_aug
# sensetivity
# sensetivity_optional_range
# extend_base_and_result
def coorAdvSens1(sequence_array_list_input,num_aug = 6,sensetivity = 0.025,sensetivity_optional_range = 0,extend_base_and_result = True):
  # num_aug -> this is multiplied by the amount of data inputted, therefore this dictates the amount of augmented executions
  # senstivity -> this dictates the max +- range of sensetivity ----> EXAMPLE: original coordinatest-> 0.6 results with 0.025 sensetivity-> 0.625 or 0.575 or 0.615 or 0.585
  sequence_array_list = copy.deepcopy(sequence_array_list_input)

  temp_allowance = 0.5

  tempExecution = []
  tempSequence = []
  tempFinalList = []
  temp = 0


  for ctr in range(num_aug):
    for execution in sequence_array_list_input:
      for sequence in execution:
        for individual_coor in sequence:
          if sensetivity_optional_range == 0:
            temp = round(rand.uniform(individual_coor - sensetivity, individual_coor + sensetivity), 8)
            # print(individual_coor, "<---->", temp)

          else:
            determiner = rand.randint(0,1)
            if determiner == 0:
              temp = round(rand.uniform(individual_coor + sensetivity + temp_allowance,individual_coor + sensetivity+sensetivity_optional_range ), 8)
              # print(inidividual_coor, "<---->", temp)
            else:
              temp = round(rand.uniform(individual_coor - sensetivity - sensetivity_optional_range,individual_coor - sensetivity - temp_allowance ), 8)
              # print(inidividual_coor, "<---->", temp)



            # if temp >= 1.0 :
            #   temp = 1
            # elif temp <= 0.00000000:
            #   temp =  0.00000001


          tempSequence.append(temp)
        temp = []
        temp_x_value = []
        temp_y_value = []

        temp_x_value_normalized = []
        temp_y_value_normalized = []

        tempSequence_normalized = []

        tempCtr = 0
        for coordinates in range(int(len(tempSequence)/2)):
          temp_x_value.append(tempSequence[tempCtr])
          tempCtr = tempCtr + 1
          temp_y_value.append(tempSequence[tempCtr])
          tempCtr = tempCtr + 1



        x_min_value = min(temp_x_value)
        x_max_value = max(temp_x_value)

        y_min_value = min(temp_y_value)
        y_max_value = max(temp_y_value)




        for content in temp_x_value:

          scaled_values = (content - x_min_value) / (x_max_value - x_min_value)
          temp_x_value_normalized.append(scaled_values)
          if scaled_values < 0:
            print("--------------------------")
            print("x_min_value --->",x_min_value)
            print("x_max_value --->",x_max_value)
            print("content --->" ,content)


        for content in temp_y_value:
          scaled_values = (content - y_min_value) / (y_max_value - y_min_value)

          temp_y_value_normalized.append(scaled_values)
          # if scaled_values < 0:
          #   print(y_min_value,y_max_value,content)

        x_value_ctr = 0
        y_value_ctr = 0

        for ctr in range(66):
          if ctr % 2 == 0:
            tempSequence_normalized.append(temp_x_value_normalized[x_value_ctr])
            x_value_ctr = x_value_ctr + 1
          else:
            tempSequence_normalized.append(temp_y_value_normalized[y_value_ctr])
            y_value_ctr = y_value_ctr + 1



        tempExecution.append(tempSequence)
        tempSequence_normalized = []




        tempSequence = []

      tempFinalList.append(tempExecution)
      tempExecution = []
  if extend_base_and_result == True:
    tempFinalList.extend(sequence_array_list)
  print('\n-------------------applied coorAdvSens1-------------------')
  print('initial len --> ',len(sequence_array_list))
  print('final len --> ',len(tempFinalList))


  return tempFinalList



# This function
# needs to be padded already before using this to prevent problems when initializing base_num_seq_aug(this determines how much sequence should be augmented)
# currently augmented seuqnce are replaced with 0 coordinates

def sequenceAdvSens1(sequence_array_list_input,num_aug = 2,sensetivity = 0.1,extend_base_and_result = True):
  sequence_array_list = copy.deepcopy(sequence_array_list_input)

  allowance_temp = 0.5

  base_num_seq_aug = int(len(sequence_array_list[0]) * sensetivity)
  print("base num aug ---> ",base_num_seq_aug)
  if base_num_seq_aug < 1:
    base_num_seq_aug = 1

  temp_rand_seq_index = []
  rand_index = 0
  tempSequence = []
  tempFinalList = []
  replacement = []
  temp = 0

  for x in range(66):
    replacement.append(0)

  for ctr in tqdm(range(num_aug), desc="sequenceAdvSens1"):
    for execution in sequence_array_list:
      temp_execution = execution
      for ctr in range(base_num_seq_aug):
        while rand_index in temp_rand_seq_index:
          rand_index = rand.randrange(1, len(temp_execution))
        temp_rand_seq_index.append(rand_index)

      for index in temp_rand_seq_index:
        temp_execution[index] = replacement
      tempFinalList.append(temp_execution)
      temp_rand_seq_index = []

  if extend_base_and_result == True:
    tempFinalList.extend(sequence_array_list)

  print('-------------------applied coorAdvSens1-------------------')
  print('initial len --> ',len(sequence_array_list))
  print('final len --> ',len(tempFinalList))
  return tempFinalList









# Load and preprocess input image
# import numpy as np


# this tests the model by feeding it certain amount of wrong and correct and validating how much accurate it is
# made this function instead of using the pre-made functions soo that i can see the value itself which may be an indicator of a problem
def checking_inputs(correct_input,wrong_input,model_path_param,model = ""):
  temp_padding_array = []

  for x in range(66):
    temp_padding_array.append(0)

  base_data = correct_input
  base_data_noise = wrong_input
  print(len(base_data))
  print(len(base_data_noise))

  compiled_data = []
  compiled_data.append(base_data)
  compiled_data.append(base_data_noise)

  temp_seq = []
  temp_execution = []

  ctr_compiled_data = 0
  correct_ctr = 0
  wrong_ctr = 0

  correct_threshod = 0.8


  # Load TFLite model
  if model == "":
    interpreter = tf.lite.Interpreter(model_path=model_path_param)
  else:
    interpreter = tf.lite.Interpreter(model_content=tf.lite.toco_convert(model))


  interpreter.allocate_tensors()
  input_tensor_index = interpreter.get_input_details()[0]['index']
  shape_needed = interpreter.get_input_details()[0]["shape"][1]

  print("shape_needed21312312 --->",shape_needed)

# convertin to float32
  for content in compiled_data:
    temp_final = []

    if ctr_compiled_data == 0:
      print("----------------correct inputs----------------")
    else:
      print("----------------wrong inputs----------------")
    for execution in content:
      while len(execution) > shape_needed:
        execution.pop()

      while len(execution) < shape_needed:
        execution.append(temp_padding_array)

      for sequence in execution:
        for coordinates in sequence:
          temp_seq.append(np.float32(coordinates))
        temp_execution.append(temp_seq)
        temp_seq = []
      temp_final.append(temp_execution)
      temp_execution=[]

    print("--->?",len(temp_final))
    for temp_final_content in temp_final:
      temp_inference = temp_final_content

      input_data = temp_final_content
      input_data = np.array(input_data)
      input_data = np.reshape(input_data, (1, shape_needed, 66))

      # Set input tensor
      interpreter.set_tensor(input_tensor_index, input_data)

      # Run inference
      interpreter.invoke()

      # Get output tensor
      output_tensor_index = interpreter.get_output_details()[0]['index']
      output_data = interpreter.get_tensor(output_tensor_index)
      print(output_data)



      # print(ctr_compiled_data)
      if ctr_compiled_data == 0 and output_data >= correct_threshod:
        correct_ctr = correct_ctr + 1

      elif ctr_compiled_data == 1 and output_data < correct_threshod:
        wrong_ctr = wrong_ctr + 1

    ctr_compiled_data = ctr_compiled_data + 1


  print("correct_input --> ",correct_ctr,"/",len(base_data))
  print("wrong_input --> ",wrong_ctr,"/",len(base_data_noise))

  return (correct_ctr / len(base_data)) * 0.5 + (wrong_ctr / len(base_data_noise)) * 0.5























