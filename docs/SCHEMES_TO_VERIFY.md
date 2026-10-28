# Government Schemes Verification Checklist

The following 11 government schemes are currently seeded with status `unverified` (`checked_by: null`, `last_checked_at: null`). In deployed environments (`is_deployed == True`), they are hidden from farmers until explicitly verified against official government portals.

To verify a scheme:
1. Open the official government URL in your browser.
2. Confirm that the scheme is active, the eligibility criteria and benefit numbers match the data, and the application process is accurate.
3. Update `backend/app/data/schemes_seed.json` with:
   - `"verification_status": "verified"`
   - `"checked_by": "<your_name_or_id>"`
   - `"last_checked_at": "<ISO_8601_date>"` (e.g., `2026-10-28T22:30:00Z`)

---

## 1. PM-KISAN — Pradhan Mantri Kisan Samman Nidhi
- **Code:** `PM-KISAN`
- **Level:** Central
- **Category:** Direct Income Support
- **Official Portal:** [https://pmkisan.gov.in/](https://pmkisan.gov.in/)
- **Claimed Benefit in Seed:** ₹6,000 per year paid in three equal four-monthly installments of ₹2,000 directly into Aadhaar-seeded bank accounts.
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 2. PMFBY — Pradhan Mantri Fasal Bima Yojana
- **Code:** `PMFBY`
- **Level:** Central
- **Category:** Crop Insurance
- **Official Portal:** [https://pmfby.gov.in/](https://pmfby.gov.in/)
- **Claimed Benefit in Seed:** Comprehensive insurance coverage against failure of the crop due to non-preventable natural risks; 2% premium for Kharif crops, 1.5% for Rabi, and 5% for annual commercial/horticultural crops.
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 3. KCC — Kisan Credit Card
- **Code:** `KCC`
- **Level:** Central
- **Category:** Agricultural Credit
- **Official Portal:** [https://www.myscheme.gov.in/schemes/kcc](https://www.myscheme.gov.in/schemes/kcc)
- **Claimed Benefit in Seed:** Timely and adequate short-term credit up to ₹3 lakh at an effective interest rate of 4% per annum upon prompt repayment.
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 4. e-NAM — National Agriculture Market
- **Code:** `E-NAM`
- **Level:** Central
- **Category:** Market Linkage
- **Official Portal:** [https://www.enam.gov.in/](https://www.enam.gov.in/)
- **Claimed Benefit in Seed:** Pan-India electronic trading portal networking existing APMC mandis for unified national agricultural marketing, transparent price discovery, and direct online payment.
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 5. PKVY — Paramparagat Krishi Vikas Yojana
- **Code:** `PKVY`
- **Level:** Central
- **Category:** Organic Farming
- **Official Portal:** [https://pgsindia-ncof.gov.in/PKVY](https://pgsindia-ncof.gov.in/PKVY)
- **Claimed Benefit in Seed:** Financial assistance of ₹50,000 per hectare for 3 years, of which ₹31,000/ha is directly provided for organic inputs (seeds, bio-fertilizers, bio-pesticides).
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 6. PM-KUSUM — Solar Pumps and Grid-Connected Solar Plants
- **Code:** `PM-KUSUM`
- **Level:** Central
- **Category:** Renewable Energy / Irrigation
- **Official Portal:** [https://mnre.gov.in/en/pm-kusum](https://mnre.gov.in/en/pm-kusum)
- **Claimed Benefit in Seed:** Up to 60% subsidy (30% Central + 30% State) for standalone solar agriculture pumps (Component B) and solarization of grid-connected pumps (Component C).
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 7. Soil Health Card Scheme
- **Code:** `SOIL-HEALTH-CARD`
- **Level:** Central
- **Category:** Soil Health
- **Official Portal:** [https://soilhealth.dac.gov.in/](https://soilhealth.dac.gov.in/)
- **Claimed Benefit in Seed:** Free bi-annual soil health cards indicating nutrient status (N, P, K, micro-nutrients) and customized fertilizer recommendations for farmers' field plots.
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 8. Kerala State Crop Insurance Scheme
- **Code:** `KERALA-CROP-INSURANCE`
- **Level:** State (Kerala)
- **Category:** Crop Insurance
- **Official Portal:** [https://keralaagriculture.gov.in/](https://keralaagriculture.gov.in/)
- **Claimed Benefit in Seed:** State-subsidized compensation for 27 notified crops for damages caused by drought, flood, landslide, wild animals, and pest infestation.
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 9. Kerala Farm Mechanization Assistance
- **Code:** `KERALA-FARM-MECHANIZATION`
- **Level:** State (Kerala)
- **Category:** Farm Equipment & Mechanization
- **Official Portal:** [https://keralaagriculture.gov.in/](https://keralaagriculture.gov.in/)
- **Claimed Benefit in Seed:** Up to 50% subsidy on procurement of power tillers, transplanters, harvesters, and irrigation pumpsets through Krishibhavan registration.
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 10. Tamil Nadu Crop Insurance Support
- **Code:** `TAMIL-NADU-CROP-INSURANCE`
- **Level:** State (Tamil Nadu)
- **Category:** Crop Insurance
- **Official Portal:** [https://www.tnagrisnet.tn.gov.in/](https://www.tnagrisnet.tn.gov.in/)
- **Claimed Benefit in Seed:** Additional state premium subvention ensuring effective zero or near-zero farmer contribution for major paddy and horticultural crop insurance under Special Crop Insurance Package.
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

---

## 11. Tamil Nadu Agricultural Mechanization Assistance
- **Code:** `TAMIL-NADU-MECHANIZATION`
- **Level:** State (Tamil Nadu)
- **Category:** Farm Equipment
- **Official Portal:** [https://www.tnagrisnet.tn.gov.in/](https://www.tnagrisnet.tn.gov.in/)
- **Claimed Benefit in Seed:** Subsidy of 40% to 50% on agricultural machinery (tractors, rotavators, power weeders) with priority allocation for SC/ST and women farmers through the Uzhavan app.
- **Verification Status:** `unverified`
- **Checked By:** `null`
- **Last Checked:** `null`

