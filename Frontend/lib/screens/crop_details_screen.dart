import 'package:flutter/material.dart';
import '../utils/language_helper.dart';

class CropDetailsScreen extends StatelessWidget {
  const CropDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          LanguageHelper.getText(
            "Crop Details",
            "വിള വിവരങ്ങൾ",
            "फसल विवरण",
            "பயிர் விவரங்கள்",
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Image.network(
              "https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b",
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    "Premium Rice",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "₹4200 / Quintal",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(),

                  ListTile(
                    leading: const Icon(
                      Icons.inventory,
                      color: Colors.green,
                    ),
                    title: Text(
                      LanguageHelper.getText(
                        "Available Quantity",
                        "ലഭ്യമായ അളവ്",
                        "उपलब्ध मात्रा",
                        "கிடைக்கும் அளவு",
                      ),
                    ),
                    subtitle:
                        const Text("50 Quintal"),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.person,
                      color: Colors.green,
                    ),
                    title: Text(
                      LanguageHelper.getText(
                        "Farmer",
                        "കർഷകൻ",
                        "किसान",
                        "விவசாயி",
                      ),
                    ),
                    subtitle:
                        const Text("Ravi Kumar"),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    title: Text(
                      LanguageHelper.getText(
                        "Location",
                        "സ്ഥലം",
                        "स्थान",
                        "இடம்",
                      ),
                    ),
                    subtitle:
                        const Text("Palakkad"),
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.star,
                      color: Colors.orange,
                    ),
                    title: Text(
                      LanguageHelper.getText(
                        "Rating",
                        "റേറ്റിംഗ്",
                        "रेटिंग",
                        "மதிப்பீடு",
                      ),
                    ),
                    subtitle:
                        const Text("4.8 / 5"),
                  ),

                  const Divider(),

                  Text(
                    LanguageHelper.getText(
                      "Quality Information",
                      "ഗുണനിലവാര വിവരം",
                      "गुणवत्ता जानकारी",
                      "தரத் தகவல்",
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const ListTile(
                    leading:
                        Icon(Icons.eco),
                    title: Text(
                      "Organic Certified",
                    ),
                  ),

                  const ListTile(
                    leading:
                        Icon(Icons.calendar_today),
                    title: Text(
                      "Harvested: 10 Aug 2026",
                    ),
                  ),

                  const SizedBox(height: 15),

                  Card(
                    color: Colors.green.shade50,
                    child: const ListTile(
                      leading:
                          Icon(Icons.smart_toy),
                      title: Text(
                        "AI Suggested Price",
                      ),
                      subtitle:
                          Text("₹4100 - ₹4300"),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child:
                        ElevatedButton.icon(
                      onPressed: () {},
                      icon:
                          const Icon(Icons.shopping_cart),
                      label: Text(
                        LanguageHelper.getText(
                          "Add To Cart",
                          "കാർട്ടിൽ ചേർക്കുക",
                          "कार्ट में जोड़ें",
                          "வண்டியில் சேர்",
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child:
                        ElevatedButton.icon(
                      onPressed: () {},
                      icon:
                          const Icon(Icons.call),
                      label: Text(
                        LanguageHelper.getText(
                          "Contact Farmer",
                          "കർഷകനെ ബന്ധപ്പെടുക",
                          "किसान से संपर्क करें",
                          "விவசாயியை தொடர்பு கொள்ளவும்",
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child:
                        ElevatedButton.icon(
                      onPressed: () {},
                      icon:
                          const Icon(Icons.flash_on),
                      label: Text(
                        LanguageHelper.getText(
                          "Buy Now",
                          "ഇപ്പോൾ വാങ്ങുക",
                          "अभी खरीदें",
                          "இப்போது வாங்கு",
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange,
                        foregroundColor:
                            Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}