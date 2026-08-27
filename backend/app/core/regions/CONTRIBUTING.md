# Regional Developer & Field Survey Team Contribution Guide

## Pinpointed District Folder Structure

Every regional developer team works exclusively inside their district folder:

```
app/core/regions/
└── <state_name>/                   ← e.g. kerala/
    ├── <state_name>.py             ← State-level metadata
    └── <district_name>/            ← e.g. palakkad/
        ├── district.py             ← District provider (code logic & source declarations)
        ├── slang.json              ← Dialect pack (local farming terminology)
        └── soil_survey.json        ← Soil survey dataset (pH, NPK, taluk/village soil profiles)
```

---

## How Regional Developers Add Data Without Modifying Core Engine

Regional developers can add or update regional survey data directly inside their district folder. The system auto-scans and loads all files on startup.

### 1. Dialect Slang Pack (`slang.json`)
Add local farming terminology so farmers can speak in their native dialect:
```json
{
  "state": "Kerala",
  "district": "Palakkad",
  "slang_mapping": {
    "net_profit": "ലാഭം (Laabham)",
    "market_price": "മാർക്കറ്റ് വില (Market Vila)"
  }
}
```

### 2. Soil Survey Dataset (`soil_survey.json`)
When field survey teams visit villages, simply add or update `soil_survey.json` inside the district folder:
```json
{
  "state": "Kerala",
  "district": "Palakkad",
  "panchayaths_and_taluks": [
    {
      "taluk": "Chittur",
      "village_panchayath": "Eruthempathy",
      "predominant_soil_type": "BLACK_COTTON_SOIL",
      "ph_range": { "min": 7.0, "max": 8.2, "avg": 7.6 },
      "organic_carbon_status": "MEDIUM",
      "nitrogen_kg_ha": 240,
      "phosphorus_kg_ha": 18,
      "potassium_kg_ha": 310,
      "suitable_crops": ["Paddy", "Groundnut", "Sugarcane"]
    }
  ]
}
```

### 3. District Code Provider (`district.py`)
Implement `BaseDistrictProvider` to declare official market sources, economic rate endpoints, and local Krishi Vigyan Kendra (KVK) centers.

---

## Zero Maintenance Core Architecture

- **No core backend code changes needed** when adding a new district or updating soil data.
- Drop your files into `app/core/regions/<state>/<district>/` — `DistrictRegionRegistry` discovers and loads everything automatically.
