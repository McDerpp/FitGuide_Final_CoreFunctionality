import os
import random as rand
from datetime import datetime
from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.http import HttpResponse, JsonResponse
import json


from modelTraining.models import DatasetInfo, ExerciseInfo
from modelTraining.modelTrainingProcess.mainTraining import trainModel

from django.contrib.sessions.backends.db import SessionStore

# CSRF IS DISABLED SHOULD BE CHANGED!


@csrf_exempt
def collect_dataset_info(request):
    print("------------------------------------------------COLELCT_DATASET!!!!")
    if request.method == 'POST':
        data = json.loads(request.body)

        # need to check if id exist
        randId = rand.randint(0, 999999999)
        url = data.get('datasetUrl')
        luminance = data.get('avgLuminance')
        numExecution = data.get('numExecution')
        avgSequence = data.get('avgSequence')
        minSequence = data.get('minSequence')
        maxSequence = data.get('maxSequence')

        # what if data is still not available?!?!?!
        file_path = request.session.get('upload_file_path')
        print("upload_file_path --> ", file_path)
        trainModel(file_path)

        dataset_info = DatasetInfo(
            datasetID=randId,
            datasetUrl=file_path,
            avgLuminance=luminance,
            numExecution=numExecution,
            avgSequence=avgSequence,
            minSequence=minSequence,
            maxSequence=maxSequence
        )

        dataset_info.save()


@csrf_exempt
def collect_exercise_info(request):
    if request.method == 'POST':
        session_key = request.META.get('HTTP_AUTHORIZATION')
        session_store = SessionStore(session_key=session_key)

        data = json.loads(request.body)

        # need to check if id exist
        randId = rand.randint(0, 999999999)
        # url = data.get('datasetUrl')
        luminance = data.get('avgLuminance')
        numExecution = data.get('numExecution')
        avgSequence = data.get('avgSequence')
        minSequence = data.get('minSequence')
        maxSequence = data.get('maxSequence')

        exercise_info = ExerciseInfo(
            exerciseID=randId,
            exerciseName=file_path,
            partAffected=luminance,
            description=numExecution,
            additionalNotes=avgSequence,
            numExecution=minSequence,
            numSet=maxSequence,
            modelID=maxSequence
        )

        exercise_info.save()


def test_connection(request):
    response = {'message': 'Connected to Django server successfully'}
    return JsonResponse(response)


# views.py

# this is for testing
@csrf_exempt
def datasetSubmit(request):
    if request.method == 'POST':

        session_key = request.META.get('HTTP_AUTHORIZATION')
        session_store = SessionStore(session_key=session_key)

        uploaded_file = request.FILES['positiveDataset']
        uploaded_file2 = request.FILES['negativeDataset']

        current_datetime = datetime.now()

        randId_dataset = rand.randint(0, 999999999)
        formatted_number = '{:07d}'.format(randId_dataset)
        final_rand_id = str(formatted_number)

        # randId_filename_correct = 'coordinates_' +  final_rand_id + '_' + month + day + year + '.txt'
        randId_filename_postive = 'coordinates_positive_' + final_rand_id + '.txt'
        randId_filename_negative = 'coordinates_negative_' + final_rand_id + '.txt'

        destination_folder = os.path.join(
            'D:/CLARK/Documents/fitguidef/BackEnd/modelTraining/', 'txtFile')

        os.makedirs(destination_folder, exist_ok=True)

        # file_name = uploaded_file.name
# ===============================================================================

        file_path = os.path.join(
            destination_folder + '/', randId_filename_postive)

        with open(file_path, 'wb') as destination_file:
            for chunk in uploaded_file.chunks():
                destination_file.write(chunk)

        file_path = os.path.join(
            destination_folder + '/', randId_filename_postive)

        with open(file_path, 'wb') as destination_file:
            for chunk in uploaded_file.chunks():
                destination_file.write(chunk)

# ===============================================================================
        file_path2 = os.path.join(
            destination_folder + '/', randId_filename_postive)

        with open(file_path2, 'wb') as destination_file:
            for chunk in uploaded_file2.chunks():
                destination_file.write(chunk)

        file_path2 = os.path.join(
            destination_folder + '/', randId_filename_postive)

        with open(file_path2, 'wb') as destination_file:
            for chunk in uploaded_file2.chunks():
                destination_file.write(chunk)
# ===============================================================================

        request.session.save()


# DatasetInfo===========================================================
        avg_luminance = request.POST.get('avgLuminance')
        num_execution = request.POST.get('numExecution')
        avg_sequence = request.POST.get('avgSequence')
        min_sequence = request.POST.get('minSequence')
        max_sequence = request.POST.get('maxSequence')
        session_key = request.POST.get('sessionKey')

        dataset_info = DatasetInfo(
            datasetID=randId_dataset,
            positiveDatasetUrl=file_path,
            negativeDatasetUrl=file_path2,
            numExecution=num_execution,
            avgSequence=avg_sequence,
            minSequence=min_sequence,
            maxSequence=max_sequence
        )

# ExerciseInfo===========================================================
        exercise_ID = rand.randint(0, 999999999)
        exercise_Name = request.POST.get('exerciseName')
        parts_Affected = request.POST.get('partsAffected')
        description = request.POST.get('description')
        additional_notes = request.POST.get('additionalNotes')
        num_execution = request.POST.get('exerciseNumExecution')
        num_set = request.POST.get('exerciseNumSet')

        model_info_instance = trainModel(file_path, session_key)

        # model_info_instance = session_store['setModelInfo']

        print("model_info_instance --> ", model_info_instance)

        exerciseInfo = ExerciseInfo(
            exerciseID=exercise_ID,
            exerciseName=exercise_Name,
            # partAffected=parts_Affected,
            # description=description,
            # additionalNotes=additional_notes,
            numExecution=num_execution,
            numSet=num_set,
            modelID=model_info_instance
        )

        exerciseInfo.save()
        # dataset_info.save()

        return JsonResponse({'message': 'File uploaded successfully'}, status=200)
    else:
        return JsonResponse({'error': 'Only POST requests are allowed'}, status=400)

# this is for testing


@csrf_exempt
def set_session_variable(request):
    session_key = request.META.get('HTTP_AUTHORIZATION')
    print("session key is this 2-->", session_key)

    if session_key:
        print("giving value")
        session_store = SessionStore(session_key=session_key)

        variable_name = 'variable_name'
        variable_value = '153153153'

        session_store[variable_name] = variable_value
        session_store.save()

        return JsonResponse({'message': 'Session variable set successfully'})
    else:
        return JsonResponse({'error': 'No session key provided'})


@csrf_exempt
def get_session_variable(request):
    session_key = request.META.get('HTTP_AUTHORIZATION')
    print("session key is this 3-->", session_key)

    if session_key:
        session_store = SessionStore(session_key=session_key)

        value = session_store.get('variable_name')
        print("Session variable value:", value)

        if value is not None:
            return JsonResponse({'value': value})
        else:
            return JsonResponse({'error': 'Session variable not found'})
    else:
        return JsonResponse({'error': 'No session key provided'})


@csrf_exempt
def generate_session_key(request):
    session_store = SessionStore()
    session_store.save()  # Save the session to generate a session key
    session_key = session_store.session_key
    print("session key is this 1-->", session_key)
    return HttpResponse(session_key)
