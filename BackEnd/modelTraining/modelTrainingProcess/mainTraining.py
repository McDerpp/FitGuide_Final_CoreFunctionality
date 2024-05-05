
from pathlib import Path
import optuna
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense
from sklearn.model_selection import train_test_split
from sklearn.datasets import load_iris
from tensorflow.keras.models import Sequential, load_model
from tensorflow.keras.layers import LSTM, Dense, Bidirectional, BatchNormalization
from tensorflow.keras.callbacks import TensorBoard, ReduceLROnPlateau, EarlyStopping, ModelCheckpoint, Callback
from tensorflow.keras.optimizers import Adam
import copy
import matplotlib.pyplot as plt
from modelTraining.modelTrainingProcess.dataAugmentations import apply_z_score, checking_inputs, common_length_sequence, concatenate_randomize_batches, convert_tf_to_tflite, coorAdvSens1, paddingV2, populate_0_input, sequenceAdvSens1, txt_pre_process
from imblearn.over_sampling import SMOTE
from tensorflow.keras.regularizers import l1, l2
from tqdm import tqdm
import numpy as np
from sklearn.model_selection import train_test_split
from collections import Counter
import random as rand
import os
from django.contrib.sessions.backends.db import SessionStore


from modelTraining.models import ModelInfo


def trainModel(positiveDataPath, negativeDataPath,  dataset_info=None, model_info=None):
    best_model = ""
    y_train = []
    X_train = []
    X_test = []
    y_test = []
    rand_batches = []
    checking_input_positive = []
    checking_input_negative = []
    best_combined_metric = 0.0
    best_model_tflite = ""
    rand_batches = []

    checking_input_positive = []
    checking_input_negative = []

    setModelInfo = ModelInfo(
        modelID="",
        modelUrl="",
        # FOR TESTING!
        valLoss=0,
        # FOR TESTING!

        valAccuracy=0
    )

    def noise_compile(input_list, sequence_number):
        compile = []
        temp = []
        final_compile = []
        for execution in input_list:
            for sequence in execution:
                compile.append(sequence)

        for seq_compiled in compile:
            temp.append(seq_compiled)
            if len(temp) == sequence_number:
                final_compile.append(temp)
                temp = []

        return final_compile

    def create_lstm_model(trial):
        nonlocal X_train
        model = Sequential()
        custom_early_stopping = EarlyStopping(
            monitor='val_loss', patience=15, restore_best_weights=True)
        lr_reduction_callback = ReduceLROnPlateau(
            monitor='val_loss', factor=0.5, patience=15, min_lr=1e-6)

        # Number of LSTM layers
        # num_lstm_layers = trial.suggest_int('num_lstm_layers', low=1, high=7)
        num_lstm_layers = 1

        # Add LSTM layers
        for i in range(num_lstm_layers):
            units = trial.suggest_int(f'lstm_units_layer_{i}', 15, 150)
            return_sequences = trial.suggest_categorical(
                f'lstm_return_sequences_layer_{i}', [True, False])
            dropout_rate_value = round(trial.suggest_float(
                f'lstm_dropout_layer_{i}', 0.0, 0.9), 2)
            recurrent_dropout_rate_value = round(trial.suggest_float(
                f'lstm_recurrent_dropout_layer_{i}', 0.0, 0.9), 2)
            learning_rate = trial.suggest_float('learning_rate', 1e-5, 1e-1)
            dropout_rate = trial.suggest_float('dropout_rate', 0.0, 0.5)

            model.add(Bidirectional(LSTM(units, return_sequences=False, activation='relu', dropout=dropout_rate_value,
                                         recurrent_dropout=recurrent_dropout_rate_value), input_shape=(len(X_train[0]), len(X_train[0][0]))))

            # if i == 0:
            #   model.add(Bidirectional(LSTM(units, return_sequences=False, activation='relu', dropout=dropout_rate_value, recurrent_dropout=recurrent_dropout_rate_value), input_shape=(len(X_train[0]),len(X_train[0][0]))))
            # elif i == num_lstm_layers - 1:
            #   model.add(Bidirectional(LSTM(units, return_sequences=False,activation='relu',dropout = dropout_rate_value,  recurrent_dropout=recurrent_dropout_rate_value)))
            # else:
            #   model.add(Bidirectional(LSTM(units, return_sequences=False,activation='relu',dropout =dropout_rate_value,  recurrent_dropout=recurrent_dropout_rate_value)))

        # Dense layer
        dense_units = trial.suggest_int('dense_units', 10, 50)
        model.add(Dense(dense_units, activation='relu'))

        # Output layer
        model.add(Dense(1, activation='sigmoid'))

        # Compile the model
        model.compile(optimizer='adam', loss='binary_crossentropy',
                      metrics=['accuracy'])

        return model

    def objective(trial):
        nonlocal X_train
        nonlocal best_combined_metric
        nonlocal rand_batches
        nonlocal checking_input_positive
        nonlocal checking_input_negative
        nonlocal best_model_tflite

        print("best_combined_metric ----> ", best_combined_metric)

        best_val_loss = 0

        model = create_lstm_model(trial)

        custom_early_stopping = EarlyStopping(
            monitor='val_loss', patience=15, restore_best_weights=True)
        lr_reduction_callback = ReduceLROnPlateau(
            monitor='val_loss', factor=0.5, patience=10, min_lr=1e-6)

        y_train_int = y_train.astype(int)
        y_test_int = y_test.astype(int)

        history = model.fit(X_train, y_train, epochs=10, batch_size=124, validation_split=0.2, callbacks=[
                            custom_early_stopping, lr_reduction_callback], verbose=0)
        # history = model.fit(X_train, y_train, epochs=100, batch_size=124, validation_split=0.2, callbacks=[
        #                     custom_early_stopping, lr_reduction_callback], verbose=0)

        test_loss, test_accuracy = model.evaluate(
            X_test, y_test_int, verbose=0)

        weight_loss = 0.5
        weight_accuracy = 0.5

        # Combine metrics into a single value
        combined_metric = weight_loss * \
            (1 - test_loss) + weight_accuracy * test_accuracy

        temp = rand_batches[0].astype(np.float32)

        id_num = str(rand.randint(1000, 9999))
        model.save(Path(
            'D:/CLARK/Documents/fitguidef/BackEnd/assets/models/nonTFLiteModels/testModel'))
        file_saved_path = convert_tf_to_tflite(Path('D:/CLARK/Documents/fitguidef/BackEnd/assets/models/nonTFLiteModels/testModel'), [1, len(X_train[0]), len(
            X_train[0][0])], temp, 'whole_model', id_num, test_loss, test_accuracy)
        checking_input_value = checking_inputs(
            checking_input_positive, checking_input_negative, file_saved_path)

        combined_metric = combined_metric * 0.5 + checking_input_value * 0.5
        print("best_combined_metric -> ", best_combined_metric,
              "combined_metric ->", combined_metric)
        print("best_model_tflite -->", best_model_tflite)
        print("os.path.exists(best_model_tflite) ----> ",
              os.path.exists(best_model_tflite))

        if best_combined_metric <= combined_metric:
            if best_model_tflite is not None and os.path.exists(best_model_tflite):
                print("replacing-->", best_model_tflite)
                os.remove(best_model_tflite)
                best_model_tflite = file_saved_path
                best_combined_metric = combined_metric
                print("replaced with-->", best_model_tflite)
            elif os.path.exists(best_model_tflite) == False:
                print("still empty model-->", best_model_tflite)
                best_model_tflite = file_saved_path
                best_combined_metric = combined_metric
        else:
            if os.path.exists(best_model_tflite):
                os.remove(file_saved_path)

        best_model = None
        return combined_metric

    def training_main(raw_positive, raw_negative, raw_noise, model_info=None):
        nonlocal X_train
        nonlocal y_train

        nonlocal X_test
        nonlocal y_test

        nonlocal rand_batches

        nonlocal checking_input_positive
        nonlocal checking_input_negative

        nonlocal best_model_tflite

        nonlocal setModelInfo

        best_val_loss = 0.0
        best_val_accuracy = 0.0
        correctDataAugmentation_final = []

        correct_data = raw_positive[0]
        incorrect_data = raw_negative[0]
        noise_data = raw_noise[0]

        correct_data_common = common_length_sequence(
            correct_data, int(len(correct_data)*0.1))
        correct_data_padded = paddingV2(correct_data_common)

        # final_correct_data = final_correct_data.reshape(-1,len(final_correct_data[0]),len(final_correct_data[0][0]))

        incorrect_data_padded = paddingV2(
            incorrect_data, len(correct_data_padded[0]))
        noise_compiled = noise_compile(noise_data, len(correct_data_padded[0]))

        negative_data = np.concatenate((noise_compiled, incorrect_data_padded))
        positive_data = correct_data_padded

        checking_input_positive = positive_data[int(
            len(positive_data)*.9):len(positive_data)]
        checking_input_negative = negative_data[int(
            len(negative_data)*.9):len(negative_data)]

        positive_data = positive_data[0:int(len(positive_data)*.89)]
        negative_data = negative_data[0:int(len(negative_data)*.89)]

        negative_label = np.zeros(len(negative_data))
        positive_label = np.ones(len(positive_data))

        rand_batches = concatenate_randomize_batches(
            positive_data, positive_label, negative_data, negative_label)
        X_train, X_test, y_train, y_test = train_test_split(
            rand_batches[0], rand_batches[1], test_size=0.2, random_state=42)
        X_train = X_train.reshape(-1, len(X_train[0]), len(X_train[0][0]))

        # Optimize hyperparameters and architecture
        study = optuna.create_study(direction='maximize')
        # study.optimize(objective, n_trials=25)
        study.optimize(objective, n_trials=1)

        # Print the best hyperparameters and architecture
        best_trial = study.best_trial
        print("Best Hyperparameters:")
        for key, value in best_trial.params.items():
            print(f"  {key}: {value}")
        print("Best Accuracy:", best_trial.value)

        # session_store = SessionStore(session_key=session_key)
        # session_store['setModelInfo'] = setModelInfo

        # print("model_info_instance(Train model) --> ",
        #       session_store['setModelInfo'])

        if (model_info == None):
            randId = rand.randint(0, 999999999)
            print("main training RETRAINING")

            setModelInfo = ModelInfo(
                modelID=randId,
                modelUrl=best_model_tflite,
                # FOR TESTING!
                valLoss=0,
                # FOR TESTING!
                valAccuracy=best_trial.value,
                datasetID=dataset_info
            )
            setModelInfo.save()
            print("main training training")

            return setModelInfo

        else:
            print("main training retraining ---->", model_info)
            if os.path.exists(model_info.modelUrl):
                os.remove(model_info.modelUrl)

            model_info.modelUrl = best_model_tflite
            model_info.valAccuracy = best_trial.value

            model_info.save()

    raw_positive_dataset = txt_pre_process(positiveDataPath, 1)
    base_data_noise = txt_pre_process(
        'D:/CLARK/Documents/fitguidef/BackEnd/assets/trainingData/noiseDatasets/noiseData1.txt', 0, True, 6)

    raw_negative_dataset = txt_pre_process(negativeDataPath, 0)

    # session_store = SessionStore(session_key=session_key)

    training_main(raw_positive_dataset, raw_negative_dataset,
                  base_data_noise, model_info)

    randId = rand.randint(0, 999999999)

    # session_store['setModelInfo'] = setModelInfo
    # print("model_info_instance(Train model) --> ",
    #       session_store['setModelInfo'])

    return setModelInfo
