
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


def trainModel(trainingDataSetFilePath, session_key):

    best_combined_metric = 0
    best_model_tflite = None

    best_val_loss = float('inf')
    best_val_accuracy = 0.0
    best_model = None
    y_train = []
    y_test = []

    # Load a sample dataset (for demonstration purposes)

    # base_data = txt_pre_process(
    #     trainingDataSetFilePath, 1, True, 3)
    base_data = txt_pre_process(
        'D:/CLARK/Documents/fitguidef/BackEnd/modelTraining/txtFile/coordinatesCollected(01-06-24----1203).txt', 1, True, 3)

    base_data_noise = txt_pre_process(
        'D:/CLARK/Documents/fitguidef/BackEnd/modelTraining/noiseDatasets/firstExerciseFitguide(Wrong)V2 (1).txt', 0, True, 3)

    best_val_loss = float('inf')
    best_val_accuracy = 0.0
    # getting 80% of data for training and testing
    correct_data_raw = base_data[0][0:int(len(base_data[0])*0.8)]
    noise_data_raw = base_data_noise[0][0:int(len(base_data_noise[0])*0.8)]

    initial_clean_up_correct = common_length_sequence(correct_data_raw)
    initial_clean_up_correct = apply_z_score(initial_clean_up_correct, 1)
    initial_clean_up_correct = paddingV2(initial_clean_up_correct)

    correctDataAugmentation = coorAdvSens1(initial_clean_up_correct, 4, 0.1)
    correctDataAugmentation = sequenceAdvSens1(correctDataAugmentation)

    final_correct_data = np.array(correctDataAugmentation)
    final_correct_data = final_correct_data.reshape(
        -1, len(final_correct_data[0]), len(final_correct_data[0][0]))

    initial_clean_up_noise = paddingV2(
        noise_data_raw, len(final_correct_data[0]))
    initial_clean_up_noise = populate_0_input(
        initial_clean_up_noise, noise_data_raw)

    wrongDataAugmentation_final = []
    # took 50% of the augmented correct data for basis for another augmentation : coordinate adversary sensivity -> this will augment the current data coordinates to make it more forgiving then add it to the list
    wrongDataAugmentation_1 = coorAdvSens1(correctDataAugmentation[0:int(len(
        correctDataAugmentation)*0.5)], num_aug=1, sensetivity=0.3, sensetivity_optional_range=.5, extend_base_and_result=False)

    #!!!!!!!!!!!THIS IS EXPERIMENTAL AND CAN BE DELTED!!!!!!!!!!!!!
    # wrongDataAugmentation_2 = coorAdvSens1(correctDataAugmentation[0:int(len(correctDataAugmentation)*0.5)],num_aug = 1,sensetivity = 0.5,sensetivity_optional_range=.8,extend_base_and_result =False)

    # took 50% of the augmented correct data this time for augmenting the sensetivity of the sequences to take into account the erratic nature of collecting data
    wrongDataAugmentation_3 = sequenceAdvSens1(correctDataAugmentation[0:int(
        len(correctDataAugmentation)*0.5)], 1, 0.25, extend_base_and_result=False)
    wrongDataAugmentation_4 = sequenceAdvSens1(correctDataAugmentation[int(len(
        correctDataAugmentation)*0.5):len(correctDataAugmentation)], 1, 0.75, extend_base_and_result=False)
    wrongDataAugmentation_5 = sequenceAdvSens1(correctDataAugmentation[0:int(
        len(correctDataAugmentation)*0.5)], 1, 0.5, extend_base_and_result=False)

    wrongDataAugmentation_6 = sequenceAdvSens1(initial_clean_up_noise[0:int(
        len(initial_clean_up_noise))], 1, 0.5, extend_base_and_result=False)
    wrongDataAugmentation_7 = sequenceAdvSens1(initial_clean_up_noise[0:int(
        len(initial_clean_up_noise))], 1, 0.9, extend_base_and_result=False)

    wrongDataAugmentation_final.extend(wrongDataAugmentation_1)
    # wrongDataAugmentation_final.extend(wrongDataAugmentation_2)
    wrongDataAugmentation_final.extend(wrongDataAugmentation_3)
    wrongDataAugmentation_final.extend(wrongDataAugmentation_4)
    wrongDataAugmentation_final.extend(wrongDataAugmentation_5)
    wrongDataAugmentation_final.extend(wrongDataAugmentation_6)
    wrongDataAugmentation_final.extend(wrongDataAugmentation_7)

    wrongDataAugmentation_final.extend(initial_clean_up_noise)

    final_wrong_data = np.array(wrongDataAugmentation_final)
    # final_wrong_data = final_wrong_data[0:len(final_correct_data)]
    final_wrong_data = final_wrong_data.reshape(
        -1, len(final_wrong_data[0]), len(final_wrong_data[0][0]))

    # train_wrong_data_temp = final_wrong_data[0:len(final_correct_data)]
    train_correct_data_label = np.ones(len(final_correct_data))
    train_wrong_data_label = np.zeros(len(final_wrong_data))

    # concatentating and randomizing of correct data and wrong data for training
    rand_batches = concatenate_randomize_batches(
        final_correct_data, train_correct_data_label, final_wrong_data, train_wrong_data_label)

    # flatten data
    num_samples, time_steps, features = rand_batches[0].shape
    data_2d = rand_batches[0].reshape(num_samples, -1)

    # ------------------------------------------------------------------------------------------------------------------------------------------------------------------[SMOTE here]->we can try lowering the data
    smote = SMOTE(sampling_strategy='auto', random_state=42)
    X_resampled, y_resampled = smote.fit_resample(data_2d, rand_batches[1])

    # !!!!!!!!!!--EXPERIMENTAL--!!!!!!!!!!!!!!!!!!!!!!!!!!--------------------trying to lower the amound to data to lessen the training time
    # X_resampled = X_resampled[0:int(len(X_resampled)*0.35)]
    # y_resampled = y_resampled[0:int(len(y_resampled)*0.35)]
    # !!!!!!!!!!--EXPERIMENTAL--!!!!!!!!!!!!!!!!!!!!!!!!!!

    # reconstructing to 3D
    final_wrong_data = X_resampled.reshape(
        -1, len(final_wrong_data[0]), len(final_wrong_data[0][0]))

    print("shape -->", rand_batches[0].shape)
    print("data_2d -->", data_2d.shape)
    print("data_3d_y_resampled -->", y_resampled.shape)
    print("data_3d_x_resampled -->", X_resampled.shape)

    # partitioning of training sets
    X_train, X_test, y_train, y_test = train_test_split(
        final_wrong_data, y_resampled, test_size=0.5, random_state=42)

    # rand_batches=concatenate_randomize_batches(final_correct_data,train_correct_data_label,train_wrong_data_temp,train_wrong_data_label)
    # X_train, X_test, y_train, y_test = train_test_split(rand_batches[0], rand_batches[1], test_size=0.8, random_state=42)

    base_data_original = base_data[0]
    base_data_noise_original = base_data_noise[0]

    base_data_validation_check = base_data_original[int(
        len(base_data_original)*0.85):int(len(base_data_original))]
    base_data_noise_validation_check = base_data_noise_original[int(
        len(base_data_noise_original)*0.85):int(len(base_data_noise_original))]

    # ======================================================[correct]=====================================================================================================
    # ------------------------------------------Initial processes-------------------------------------------------------

    # initial augmentation cleaning of outliers

    def create_lstm_model(trial):
        model = Sequential()

        custom_early_stopping = EarlyStopping(
            monitor='val_loss', patience=10, restore_best_weights=True)

        lr_reduction_callback = ReduceLROnPlateau(
            monitor='val_loss', factor=0.5, patience=10, min_lr=1e-6)

        # Number of LSTM layers
        num_lstm_layers = trial.suggest_int('num_lstm_layers', low=2, high=5)
        # Add LSTM layers
        for i in range(num_lstm_layers):
            units = trial.suggest_int(f'lstm_units_layer_{i}', 15, 100)
            return_sequences = trial.suggest_categorical(
                f'lstm_return_sequences_layer_{i}', [True, False])
            dropout_rate_value = round(trial.suggest_float(
                f'lstm_dropout_layer_{i}', 0.0, 0.7), 2)
            recurrent_dropout_rate_value = round(trial.suggest_float(
                f'lstm_recurrent_dropout_layer_{i}', 0.0, 0.7), 2)

            learning_rate = trial.suggest_float('learning_rate', 1e-5, 1e-1)
            dropout_rate = trial.suggest_float('dropout_rate', 0.0, 0.5)

            if i == 0:
                model.add(Bidirectional(LSTM(units, return_sequences=True, activation='relu', dropout=dropout_rate_value,
                          recurrent_dropout=recurrent_dropout_rate_value), input_shape=(len(final_correct_data[0]), len(final_correct_data[0][0]))))
            elif i == num_lstm_layers - 1:
                model.add(Bidirectional(LSTM(units, return_sequences=False, activation='relu',
                          dropout=dropout_rate_value,  recurrent_dropout=recurrent_dropout_rate_value)))
            else:
                model.add(Bidirectional(LSTM(units, return_sequences=True, activation='relu',
                          dropout=dropout_rate_value,  recurrent_dropout=recurrent_dropout_rate_value)))

        # Dense layer
        dense_units = trial.suggest_int('dense_units', 10, 100)
        model.add(Dense(dense_units, activation='relu'))

        # Output layer
        model.add(Dense(1, activation='sigmoid'))

        # Compile the model
        model.compile(optimizer='adam',
                      loss='binary_crossentropy', metrics=['accuracy'])

        return model

    def objective(trial):
        nonlocal best_combined_metric
        nonlocal best_model

        nonlocal y_train
        nonlocal y_test

        nonlocal best_model_tflite

        nonlocal best_val_loss
        nonlocal best_val_accuracy
        print("============================================================== best_combined_metric",
              best_combined_metric)
        model = create_lstm_model(trial)

        custom_early_stopping = EarlyStopping(
            monitor='val_loss', patience=10, restore_best_weights=True)
        lr_reduction_callback = ReduceLROnPlateau(
            monitor='val_loss', factor=0.5, patience=10, min_lr=1e-6)

        y_train_int = y_train.astype(int)
        y_test_int = y_test.astype(int)

    # executing of model

        history = model.fit(X_train, y_train, epochs=20, batch_size=256, validation_split=0.2, callbacks=[
                            custom_early_stopping, lr_reduction_callback], verbose=0)

        test_loss, test_accuracy = model.evaluate(
            X_test, y_test_int, verbose=0)

        weight_loss = 0.5
        weight_accuracy = 0.5

        # Combine metrics into a single value
        combined_metric = weight_loss * \
            (1 - test_loss) + weight_accuracy * test_accuracy

        temp = rand_batches[0].astype(np.float32)

        id_num = str(rand.randint(1000, 9999))
        nonTflitePath = "D:/CLARK/Documents/fitguidef/BackEnd/modelTraining/trainedModel/non-tflite" + \
            "/"+os.path.basename(trainingDataSetFilePath) + "_nonTfLite"
        model.save(nonTflitePath)

        # file_saved_path = convert_tf_to_tflite('/content/testingModel', [1, len(final_correct_data[0]), len(
        file_saved_path = convert_tf_to_tflite(nonTflitePath, [1, len(final_correct_data[0]), len(

            final_correct_data[0][0])], temp, 'whole_model', id_num, test_loss, test_accuracy)
        checking_input_value = checking_inputs(
            base_data_validation_check, base_data_noise_validation_check, file_saved_path)

        combined_metric = combined_metric * 0.5 + checking_input_value * 0.5

        # if best_combined_metric <= combined_metric:
        #     if best_model_tflite is not None and os.path.exists(best_model_tflite):
        #         print("replacing-->", best_model_tflite)
        #         os.remove(best_model_tflite)
        #         best_model_tflite = file_saved_path
        #         best_combined_metric = combined_metric                
        #         best_val_loss = test_loss
        #         best_val_accuracy = test_accuracy
        #         print("replaced with-->", best_model_tflite)
        #     elif best_model_tflite is None:
        #         print("still empty model-->", best_model_tflite)
        #         best_model_tflite = file_saved_path
        #         best_combined_metric = combined_metric
        #         best_val_loss = test_loss
        #         best_val_accuracy = test_accuracy


        if best_combined_metric <= combined_metric:
            if best_model_tflite is not None and os.path.exists(best_model_tflite):
                print("replacing-->", best_model_tflite)
                os.remove(best_model_tflite)
                print("replaced with-->", best_model_tflite)
            elif best_model_tflite is None:
                print("still empty model-->", best_model_tflite)
            best_model_tflite = file_saved_path
            best_combined_metric = combined_metric
            best_val_loss = test_loss
            best_val_accuracy = test_accuracy
        else:
            if os.path.exists(file_saved_path):
                os.remove(file_saved_path)

        best_model = None
        print(
            "===========================================================COMBINED METRIC IS[3] -> ", combined_metric)

        return combined_metric

    # Optimize hyperparameters and architecture
    study = optuna.create_study(direction='maximize')
    # --------------------------------------------------------------------------//currently debugging change it back to 15 after debugging//
    study.optimize(objective, n_trials=1)

    # Print the best hyperparameters and architecture
    best_trial = study.best_trial
    print("Best Hyperparameters:")
    for key, value in best_trial.params.items():
        print(f"  {key}: {value}")
    print("Best Accuracy:", best_trial.value)

    session_store = SessionStore(session_key=session_key)


    randId = rand.randint(0, 999999999)

    setModelInfo = ModelInfo(
        modelID=randId,
        modelUrl=best_model_tflite,
        valLoss=best_val_loss,
        valAccuracy=best_val_accuracy
    )
    setModelInfo.save()




    session_store['setModelInfo'] = setModelInfo
    print("model_info_instance(Train model) --> ",session_store['setModelInfo'])


    return setModelInfo
    # setModelInfo.save()


    # NOTE TO SELF!
    # consider having random inputs in the correct data as a noise instead of just a 0
