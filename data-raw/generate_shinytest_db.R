# Function to generate a test database for dummy data to use within application

## 0 - Housekeeping ----

# Load packages ----
# Database
library(DBI)
library(RSQLite)

# Data wrangling
library(tibble)
library(dplyr)
library(lubridate)
library(purrr)

# Create ID and fake values
library(uuid)
library(charlatan)

# Settings ----
# Set seed for reproducibility
set.seed(123)

# Create database connection ----

db <- dbConnect(RSQLite::SQLite(), "data/test_data.sqlite")


## 1 - Helper functions ----

# Generate a fake CHI number
generate_chi_number <- function(n) {
  paste0(sample(35:99, n, replace = TRUE),
         sample(15:99, n, replace = TRUE),
         sample(1000:9999, n, replace = TRUE))
}

# Generate a fake postcode
generate_postcode <- function(n) {
  paste0(
    sample(c("AA", "BD", "DW", "FF", "FV", "GP", "GG", "HL", "LS", "LN",
             "OI", "SI", "TS", "WI"), n, replace = TRUE),
    sample(1:9, n, replace = TRUE),
    " ",
    sample(1:9, n, replace = TRUE),
    sample(LETTERS, n, replace = TRUE),
    sample(LETTERS, n, replace = TRUE)
  )
}

## 2 - Create tables ----

# NHS Boards ----
nhs_boards <- tibble(
  board_id = 1:14,
  board_name = c(
    "NHS Ayrshire and Arran",
    "NHS Borders",
    "NHS Dumfries and Galloway",
    "NHS Fife",
    "NHS Forth Valley",
    "NHS Grampian",
    "NHS Greater Glasgow and Clyde",
    "NHS Highland",
    "NHS Lanarkshire",
    "NHS Lothian",
    "NHS Orkney",
    "NHS Shetland",
    "NHS Tayside",
    "NHS Western Isles"
  )
)

dbWriteTable(db, "nhs_boards", nhs_boards, overwrite = TRUE)

# Services ----
services <- map_df(1:nrow(nhs_boards), function(i) {
  board <- nhs_boards$board_name[i]
  n_services <- case_when(
    board == "NHS Greater Glasgow and Clyde" ~ 6,
    board == "NHS Lothian" ~ 5,
    board == "NHS Ayrshire and Arran" ~ 5,
    board == "NHS Lanarkshire" ~ 3,
    TRUE ~ 1
  )

  tibble(
    service_id = UUIDgenerate(n = n_services),
    board_id = i,
    service_name = paste0(charlatan::ch_company(n = n_services), " Service")
  )
})

dbWriteTable(db, "services", services, overwrite = TRUE)

# Service Users ----
n_users <- 7500

service_users <- tibble(
  service_user_id = UUIDgenerate(n = n_users),
  chi_number = generate_chi_number(n_users),
  first_name = charlatan::ch_name(n_users),
  date_of_birth = sample(seq(as.Date('1800/01/01'), as.Date('1900/12/31'), by="day"), n_users),
  sex = sample(c("M", "F", "Other"), n_users, replace = TRUE, prob = c(0.48, 0.48, 0.04)),
  postcode = generate_postcode(n_users),
  ethnicity = sample(c("White - Scottish", "White - Other", "Asian", "African or Black", "Other", "Prefer not to say"),
                     n_users, replace = TRUE, prob = c(0.51, 0.04, 0.02, 0.01, 0.01, 0.4))
)

dbWriteTable(db, "service_users", service_users, overwrite = TRUE)

# Referral Sources ----
referral_sources <- tibble(
  referral_source_id = 1:10,
  source_name = c("GP", "Self-Referral", "Hospital", "Social Work",
                  "Mental Health Services", "Education Services", "Police Scotland",
                  "Third Sector", "Family/Friend", "Other"),
  source_category = c("Healthcare", "Self", "Healthcare", "Social Care",
                      "Healthcare", "Education", "Criminal Justice",
                      "Community", "Self", "Other")
)

dbWriteTable(db, "referral_sources", referral_sources, overwrite = TRUE)

# Treatment Types ----
treatment_types <- tibble(
  treatment_type_id = 1:12,
  treatment_name = c("CBT", "Group Therapy", "Individual Counseling",
                     "Family Therapy", "Crisis Intervention", "Medication Management",
                     "Art Therapy", "Occupational Therapy", "Physical Health Support",
                     "Social Skills Training", "Substance Use Treatment",
                     "Support Group"),
  treatment_category = c("Psychological", "Psychological", "Psychological",
                         "Family", "Crisis", "Medical",
                         "Creative", "Occupational", "Physical",
                         "Social", "Addiction", "Support")
)

dbWriteTable(db, "treatment_types", treatment_types, overwrite = TRUE)

# Episodes ----
n_episodes <- 20000

episodes <- tibble(
  episode_id = UUIDgenerate(n = n_episodes),
  service_user_id = sample(service_users$service_user_id, n_episodes, replace = TRUE),
  service_id = sample(services$service_id, n_episodes, replace = TRUE),
  referral_date = sample(seq(as.Date('2019/01/01'), as.Date('2023/12/31'), by="day"), n_episodes, replace = TRUE),
  referral_source_id = sample(referral_sources$referral_source_id, n_episodes, replace = TRUE),
  discharged_before_treatment = sample(c(TRUE, FALSE), n_episodes, prob = c(0.15, 0.85), replace = TRUE),
  episode_status = "Active",
  episode_end_date = as.Date(NA)
)

# Add end dates for discharged episodes
discharged_episodes <- episodes$discharged_before_treatment
episodes$episode_status[discharged_episodes] <- "Discharged"
episodes$episode_end_date[discharged_episodes] <-
  episodes$referral_date[discharged_episodes] + sample(1:30, sum(discharged_episodes), replace = TRUE)

dbWriteTable(db, "episodes", episodes, overwrite = TRUE)

# Treatments ----
active_episodes <- episodes$episode_id[!episodes$discharged_before_treatment]
n_single_treatment <- floor(length(active_episodes) * 0.8)
n_multiple_treatments <- length(active_episodes) - n_single_treatment

treatment_episodes <- c(
  active_episodes[1:n_single_treatment],
  rep(active_episodes[(n_single_treatment + 1):length(active_episodes)], each = 2)
)

treatments <- tibble(
  treatment_id = UUIDgenerate(n = length(treatment_episodes)),
  episode_id = treatment_episodes,
  treatment_type_id = sample(treatment_types$treatment_type_id, length(treatment_episodes), replace = TRUE),
  start_date = as.Date(NA),
  end_date = as.Date(NA),
  outcome_score = sample(1:10, length(treatment_episodes), replace = TRUE),
  completion_status = sample(c("Completed", "Ongoing", "Discontinued"),
                             length(treatment_episodes), prob = c(0.6, 0.3, 0.1), replace = TRUE)
)

# Set treatment dates and update episode status
for(i in 1:nrow(treatments)) {
  episode_dates <- episodes[episodes$episode_id == treatments$episode_id[i], ]
  treatments$start_date[i] <- episode_dates$referral_date + sample(0:30, 1)

  if(treatments$completion_status[i] != "Ongoing") {
    max_end_date <- if_else(is.na(episode_dates$episode_end_date),
                            Sys.Date(),
                            episode_dates$episode_end_date)
    treatments$end_date[i] <- treatments$start_date[i] +
      sample(30:as.numeric(max_end_date - treatments$start_date[i]), 1)
  }

  # Set episode_status to discharged if treatment is completed and add episode end date after treatment end date
  if(treatments$completion_status[i] == "Completed") {
    episodes$episode_status[episodes$episode_id == treatments$episode_id[i]] <- "Discharged"
    episodes$episode_end_date[episodes$episode_id == treatments$episode_id[i]] <- treatments$end_date[i]
  }
}

dbWriteTable(db, "treatments", treatments, overwrite = TRUE)

# Assessments ----
create_assessment_row <- function(episode_id, treatment_date) {
  tibble(
    assessment_id = UUIDgenerate(),
    episode_id = episode_id,
    assessment_date = treatment_date + sample(0:30, 1),
    assessment_type = "Initial",
    social_score = sample(0:10, 1),
    housing_score = sample(0:10, 1),
    health_score = sample(0:10, 1),
    education_score = sample(0:10, 1),
    employment_score = sample(0:10, 1),
    finance_score = sample(0:10, 1),
    wellbeing_score = sample(0:10, 1),
    risk_score = sample(0:10, 1)
  )
}

# Generate assessments for 65% of episodes in batches
batch_size <- 1000
n_assessed_episodes <- floor(length(active_episodes) * 0.65)
assessed_episodes <- sample(active_episodes, n_assessed_episodes)

# Process in batches
message("Starting assessment generation...")
total_batches <- ceiling(n_assessed_episodes / batch_size)

for(batch in 1:total_batches) {
  message(sprintf("Processing batch %d of %d", batch, total_batches))

  # Calculate batch indices
  start_idx <- ((batch - 1) * batch_size) + 1
  end_idx <- min(batch * batch_size, n_assessed_episodes)

  # Get episode IDs for this batch
  batch_episodes <- assessed_episodes[start_idx:end_idx]

  # Get treatment dates for these episodes
  batch_treatments <- dbGetQuery(db, sprintf(
    "SELECT episode_id, start_date FROM treatments
     WHERE episode_id IN ('%s')
     GROUP BY episode_id",
    paste(batch_episodes, collapse = "','")
  ))

  # Generate assessments for this batch
  batch_assessments <- map_df(1:nrow(batch_treatments), function(i) {
    create_assessment_row(
      batch_treatments$episode_id[i],
      as.Date(batch_treatments$start_date[i])
    )
  })

  # Write batch to database
  dbWriteTable(db, "assessments", batch_assessments, append = TRUE)

  # Clean up to free memory
  rm(batch_assessments)
  gc()
}

message("Assessment generation complete!")

# Create indexes
dbExecute(db, "CREATE INDEX idx_episodes_service_user ON episodes(service_user_id)")
dbExecute(db, "CREATE INDEX idx_episodes_service ON episodes(service_id)")
dbExecute(db, "CREATE INDEX idx_treatments_episode ON treatments(episode_id)")
dbExecute(db, "CREATE INDEX idx_assessments_episode ON assessments(episode_id)")

# Create data dictionary
data_dictionary <- list(
  nhs_boards = names(nhs_boards),
  services = names(services),
  service_users = names(service_users),
  referral_sources = names(referral_sources),
  treatment_types = names(treatment_types),
  episodes = names(episodes),
  treatments = names(treatments),
  assessments = names(assessments)
)

writeLines(
  yaml::as.yaml(data_dictionary),
  "data-raw/data_dictionary.yaml"
)

#
