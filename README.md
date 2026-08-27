# Agry-Key 🌾

Unified Food Economy Intelligence Platform.

> [!NOTE]
> This `README.md` is a shared workspace for all engineering teams (Backend, Frontend, Database/Data Integration, and Field Survey Teams). Please maintain your respective section documentation cleanly.

---

## The Problem

Farmers and consumers lack real-time market knowledge — what to grow, when to grow it, and what it is actually worth right now on their land. While raw data exists across government portals, it remains inaccessible because it is complex, text-heavy, and difficult to navigate. Most agri-tech applications are equally hard to use, requiring complex forms and technical literacy that working farmers do not have time for.

---

## What Agry-Key Does

Agry-Key bridges this gap with a voice-first platform that speaks directly to producers in their regional language and local dialect — removing complex forms and technical barriers.

- **Pinpointed Regional Intelligence**: Pinpoint calculations down to the specific district/taluk level for input costs (fuel, fertilizer, labour, electricity, feed, transport) and produce prices.
- **Unified Food Portfolio**: Combines agriculture, livestock, poultry, dairy, and aquaculture under a single profile with cross-sector synergy calculations.
- **Zero-Touch Voice Experience**: Automatically detects location and speaks in the native language — zero typing or menu navigation required.
- **Verified Data & Anti-Fraud**: Direct integration with official primary sources and cryptographic verification for fertilizer prices and produce authenticity.

---

## Project Structure

- `backend/` — FastAPI backend server, dynamic regional plugin engine, and AI intelligence agents.
  - `backend/app/core/regions/` — **Pinpointed Regional Plugin Hierarchy** (`<state>/<district>/`).
- `frontend/` — Cross-platform mobile/web application (Frontend Team).
- `database/` — Database schema definitions, migrations, and live primary dataset ingestion (Database Team).

---

## Contributing & Regional Plugins

Agry-Key uses a **zero-code-change plugin system** for region-specific datasets:

```
app/core/regions/
└── <state>/
    ├── <state>.py              ← State-level provider contract
    └── <district>/
        ├── district.py         ← Mandi, economic & KVK source declarations
        ├── slang.json          ← Local farming dialect vocabulary
        └── soil_survey.json    ← Fill-in-the-blanks ground soil test template
```

For detailed guidelines on contributing regional slang or soil survey datasets, see the **[Regional Developer Contribution Guide](file:///d:/Agry-key/backend/app/core/regions/CONTRIBUTING.md)**.

---

## Data Policy

- **Zero Fake Data**: The backend contains zero hardcoded/mock prices or false contact numbers.
- **Live Fetching**: Primary economic data (PPAC fuel rates, mFMS fertilizer MRPs, IMD weather, Agmarknet mandi rates) is fetched live by Phase 4 AI Agents.
- **Ground Surveys**: Regional soil test data is populated directly by field survey teams into `soil_survey.json` or the `district_soil_surveys` database table.

---

## Project Roadmap

The complete project roadmap and active development issues across all teams are tracked on [GitHub Issues](https://github.com/Midhun-M-git/Agry-Key/issues).

---

## License

- **Open Source Community Use**: Licensed under the [GNU AGPLv3](LICENSE) for open-source and non-commercial community contributions.
- **Commercial & Monetary Use**: Any commercial deployment, monetization, or proprietary hosting requires a paid Commercial License from the author (Contact: `mmidhun781@gmail.com`).
