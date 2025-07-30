import os
import matplotlib.pyplot as plt
import pandas as pd
from pyspark.sql import SparkSession
from pyspark.ml.feature import VectorAssembler
from pyspark.ml.classification import LogisticRegression

os.environ["HADOOP_HOME"] = "C:\\winutils"
os.environ["PYSPARK_PYTHON"] = "python"

csv_monthly = "monthly_alcohol_fatal_crashes.csv"
monthly_df = pd.read_csv(csv_monthly)

months = monthly_df["Month"].tolist()
rates = monthly_df["FatalCrashRate"].tolist()
average_fatal_rate = sum(rates) / len(rates)
print(f"\n[INFO] Average monthly fatal crash rate due to alcohol in 2019: {average_fatal_rate:.2f}%")

plt.figure(figsize=(10, 5))
plt.plot(months, rates, marker='o', color='red')
plt.xticks(rotation=45)
plt.title("Monthly Alcohol-Impaired Fatal Crash Rates (2019)")
plt.ylabel("% of Fatal Crashes")
plt.grid(True)
plt.tight_layout()
plt.savefig("monthly_fatal_crash_trends.png")
print("[INFO] Information saved and put in 'monthly_fatal_crash_trends.png'")

spark = SparkSession.builder.appName("DrunkDrivingFatalityEstimator").getOrCreate()
csv_bac_training = "bac_fatality_training_data.csv"
bac_data = spark.read.csv(csv_bac_training, header=True, inferSchema=True)

assembler = VectorAssembler(inputCols=["BAC"], outputCol="features")
assembled_data = assembler.transform(bac_data)

lr = LogisticRegression(featuresCol="features", labelCol="Fatal")
model = lr.fit(assembled_data)

bac_samples = [x / 1000 for x in range(0, 101, 2)]
test_df = spark.createDataFrame([(bac,) for bac in bac_samples], ["BAC"])
test_features = assembler.transform(test_df)
predictions = model.transform(test_features)

bac_levels = []
death_probs = []

for row in predictions.select("BAC", "probability").collect():
    bac = row["BAC"]
    prob = row["probability"][1]
    bac_levels.append(bac)
    death_probs.append(prob)

plt.figure(figsize=(10, 5))
plt.plot(bac_levels, death_probs, color='blue', linewidth=2)
plt.title("Predicted Fatal Crash Probability vs BAC (0.00–0.10)")
plt.xlabel("BAC (Blood Alcohol Content)")
plt.ylabel("Probability of Fatality")
plt.grid(True)
plt.tight_layout()
plt.savefig("fatality_probability_vs_bac.png")
print("[INFO] Information saved to 'fatality_probability_vs_bac.png'")

california_population = 39_500_000
injuries_per_100k = 835
alcohol_fatal_crash_share = average_fatal_rate / 100
estimated_total_crashes = (injuries_per_100k / 100_000) * california_population

fatal_probs = [p for b, p in zip(bac_levels, death_probs) if b >= 0.08]
avg_drunk_fatal_prob = sum(fatal_probs) / len(fatal_probs)
expected_deaths = int(estimated_total_crashes * alcohol_fatal_crash_share * avg_drunk_fatal_prob)

print("\n[CALIFORNIA ESTIMATE]")
print(f"Total traffic injuries (estimate): {int(estimated_total_crashes):,}")
print(f"Alcohol-related crash share: {average_fatal_rate:.2f}%")
print(f"Avg fatality probability (BAC ≥ 0.08): {avg_drunk_fatal_prob:.2f}")
print(f"Estimated alcohol-related deaths in CA (2019): {expected_deaths:,}")

spark.stop()
