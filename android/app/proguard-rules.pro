# WorkManager (used by google_mobile_ads / Firebase Cloud Messaging).
# Room generates WorkDatabase_Impl at annotation-processing time; release R8
# (AGP 9) strips it, crashing at startup with:
#   RuntimeException: Failed to create an instance of androidx.work.impl.WorkDatabase
-keep class androidx.work.impl.** { *; }
-dontwarn androidx.work.impl.**