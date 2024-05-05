from django.db import models


class ExerciseInfo(models.Model):
    # change this to actual userID or anything that refers to the user
    userID = models.CharField(max_length=100, default='696969',)
    exerciseID = models.AutoField(primary_key=True)
    exerciseDemo = models.CharField(max_length=100)
    exerciseName = models.CharField(max_length=100)
    ignoreCoordinates = models.CharField(max_length=300)
    numExecution = models.IntegerField()
    numSet = models.IntegerField()

class DatasetInfo(models.Model):
    datasetID = models.AutoField(primary_key=True)
    exerciseID = models.ForeignKey(ExerciseInfo, on_delete=models.CASCADE)
    datasetURL = models.CharField(max_length=250)
    numExecution = models.IntegerField()
    avgSequence = models.FloatField()
    minSequence = models.IntegerField()
    maxSequence = models.IntegerField()
    isPositive = models.BooleanField(default=False)

class ModelInfo(models.Model):
    modelID = models.AutoField(primary_key=True)
    datasetID = models.ForeignKey(DatasetInfo, on_delete=models.CASCADE)
    modelUrl = models.CharField(max_length=300)
    valLoss = models.FloatField()
    valAccuracy = models.FloatField()



