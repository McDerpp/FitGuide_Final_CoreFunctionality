from django.urls import path
from .views import datasetSubmit, collect_dataset_info, generate_session_key, get_session_variable, set_session_variable,collect_exercise_info

urlpatterns = [
    path('datasetSubmit/', datasetSubmit, name='datasetSubmit'),
    path('collect_dataset_info/', collect_dataset_info, name='collect_dataset_info'),
    path('set_session_variable/', set_session_variable, name='set_session_variable'),
    path('get_session_variable/', get_session_variable, name='get_session_variable'),
    path('generate_session_key/', generate_session_key, name='generate_session_key'),
    path('collect_exercise_info/', collect_exercise_info, name='collect_exercise_info'),


    

]
