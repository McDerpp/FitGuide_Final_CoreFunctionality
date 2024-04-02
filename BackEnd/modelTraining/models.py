from django.db import models


class DatasetInfo(models.Model):
    datasetID = models.IntegerField(primary_key=True)
    datasetUrl = models.CharField(max_length=100)
    avgLuminance = models.FloatField()
    # avgPoseConfidence =models.FloatField() ---------------------> for future
    numExecution = models.IntegerField()
    avgSequence = models.FloatField()
    minSequence = models.IntegerField()
    maxSequence = models.IntegerField()


class ModelInfo(models.Model):
    modelID = models.IntegerField(primary_key=True)
    modelUrl = models.CharField(max_length=300)
    valLoss = models.FloatField()
    valAccuracy = models.FloatField()
    # trainingDuration = models.FloatField() ---------------------> for future


class ExerciseInfo(models.Model):
    exerciseID = models.IntegerField(primary_key=True)
    exerciseName = models.CharField(max_length=100)
    partAffected = models.CharField(max_length=100)
    description = models.CharField(max_length=500)
    additionalNotes = models.CharField(max_length=500)
    numExecution = models.IntegerField()
    numSet = models.IntegerField()
    modelID = models.ForeignKey(ModelInfo, on_delete=models.CASCADE)


class TrainingInfo(models.Model):
    trainingInstanceKey = models.IntegerField(primary_key=True)
    model = models.ForeignKey(ModelInfo, on_delete=models.CASCADE)
    dataset = models.ForeignKey(DatasetInfo, on_delete=models.CASCADE)


class UserTrainingInfo(models.Model):
    userId = models.IntegerField(primary_key=True)
    trainingInstanceKey = models.ForeignKey(TrainingInfo, on_delete=models.CASCADE)



