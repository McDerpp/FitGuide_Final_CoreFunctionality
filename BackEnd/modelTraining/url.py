from django.urls import path
from .views import datasetSubmit, generate_session_key, get_model, get_retrain_info, get_session_variable, retrain_model, set_session_variable, collect_exercise_info, get_demo

urlpatterns = [
    path('datasetSubmit/', datasetSubmit, name='datasetSubmit'),
    path('set_session_variable/', set_session_variable,
         name='set_session_variable'),
    path('get_session_variable/', get_session_variable,
         name='get_session_variable'),
    path('generate_session_key/', generate_session_key,
         name='generate_session_key'),
    path('collect_exercise_info/', collect_exercise_info,
         name='collect_exercise_info'),
    path('get_retrain_info/', get_retrain_info,
         name='get_retrain_info'),
    path('get_model/<int:exercise_ID>/', get_model,
         name='get_model'),
    path('get_demo/<int:exercise_ID>/', get_demo,
         name='get_demo'),
    path('retrain_model/', retrain_model,
         name='retrain_model'),




]
