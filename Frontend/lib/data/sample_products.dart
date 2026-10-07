import '../models/product.dart';

/// Verified agricultural benchmark products for offline reference
List<Product> sampleProducts = [
  Product(
    id: "1",
    name: "Palakkadan Matta Rice (Vadanappally)",
    category: "Grains",
    farmerName: "Alathur Farmers Cooperative",
    location: "Palakkad, Kerala",
    price: 48,
    quantity: "2500 Quintal",
    imageUrl: "",
    description: "GI-tagged authentic red parboiled rice, rich in magnesium and minerals.",
  ),
  Product(
    id: "2",
    name: "Wayanad Nendran Banana",
    category: "Fruits",
    farmerName: "Wayanad Organic Agro Society",
    location: "Sulthan Bathery, Wayanad",
    price: 38,
    quantity: "1500 Kg",
    imageUrl: "",
    description: "GI-tagged premium culinary and table banana with high potassium content.",
  ),
  Product(
    id: "3",
    name: "Kuttiyadi High-Yield Coconut",
    category: "Plantation",
    farmerName: "Malabar Coconut Producer Company",
    location: "Vadakara, Kozhikode",
    price: 44,
    quantity: "10000 Nuts",
    imageUrl: "",
    description: "Heavy copra content, rich oil percentage, harvested directly from palm groves.",
  ),
];