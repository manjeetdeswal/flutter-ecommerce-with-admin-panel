# 🛒 Full-Stack Flutter E-Commerce & Merchant Portal

A complete, production-ready e-commerce application built with **Flutter** and **Firebase**. This project goes beyond a simple UI clone by implementing a dual-role system: a beautiful storefront for customers to browse and buy, and a secure, real-time control center for merchants to manage their business.

## 📱 Screenshots

<p align="center">
  <img src="https://github.com/manjeetdeswal/flutter-ecommerce-with-admin-panel/blob/master/ss/Screenshot_20260315-205700.png" width="23%" alt="" />
  <img src="https://github.com/manjeetdeswal/flutter-ecommerce-with-admin-panel/blob/master/ss/Screenshot_20260315-205705.png" width="23%" alt="" />
  <img src="https://github.com/manjeetdeswal/flutter-ecommerce-with-admin-panel/blob/master/ss/Screenshot_20260315-205846.png" width="23%" alt="" />
  <img src="https://github.com/manjeetdeswal/flutter-ecommerce-with-admin-panel/blob/master/ss/Screenshot_20260315-205850.png" width="23%" alt="" />
</p>

<p align="center">
  <img src="https://github.com/manjeetdeswal/flutter-ecommerce-with-admin-panel/blob/master/ss/Screenshot_20260315-205959.png" width="23%" alt="" />
  <img src="https://github.com/manjeetdeswal/flutter-ecommerce-with-admin-panel/blob/master/ss/Screenshot_20260315-210003.png" width="23%" alt="" />
  <img src="https://github.com/manjeetdeswal/flutter-ecommerce-with-admin-panel/blob/master/ss/Screenshot_20260315-210006.png" width="23%" alt="" />
  <img src="https://github.com/manjeetdeswal/flutter-ecommerce-with-admin-panel/blob/master/ss/Screenshot_20260315-210016.png" width="23%" alt="" />
</p>

## ✨ Key Features

### 🛍️ Customer Storefront
* **Dynamic Product Discovery:** Browse products via categorized grids or view the latest additions on the home screen.
* **Interactive Product Details:** Features a swipeable image carousel with a custom **pinch-to-zoom full-screen gallery**.
* **Real-Time Reviews & Ratings:** Customers can leave 1-to-5 star reviews, edit their past reviews, and see dynamic visual rating progress bars. 
* **Stateful Cart Management:** Powered by Riverpod for instant, lag-free cart updates, quantity adjustments, and total price calculations.
* **Seamless Checkout:** Secure order placement linking shipping addresses directly to the user's profile.

### 🏬 Merchant Dashboard (Role-Based Access)
* **Live Command Center:** A quick-action dashboard displaying recently added products and store metrics in real-time.
* **Advanced Inventory Management:** Add, edit, or delete products instantly. Includes dynamic text fields for multiple image URLs and direct **device gallery uploads** via Firebase Cloud Storage.
* **Order Tracking:** Monitor incoming customer orders in real-time and update fulfillment statuses (Placed -> Shipped -> Delivered).
* **Customer Engagement:** Merchants can read customer reviews and post official "Response from Merchant" replies directly to the product page.
* **Store Profile:** Manage public-facing business details and support contact information.

## 🛠️ Tech Stack
* **Frontend:** Flutter (Dart)
* **State Management:** Riverpod
* **Backend as a Service (BaaS):** Firebase
  * **Authentication:** Secure user login and role-based routing (Customer vs. Merchant).
  * **Cloud Firestore:** Real-time NoSQL database for products, users, orders, and reviews.
  * **Cloud Storage:** Secure hosting for physical product image uploads.



### Installation

1. Clone the repository:
   ```bash
   git clone [https://github.com/yourusername/your-repo-name.git](https://github.com/yourusername/your-repo-name.git)
   ```

2. Navigate to the project directory:
   ```bash
   cd your-repo-name
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. **Firebase Setup:** * This project requires a Firebase backend. You will need to create your own Firebase project, enable Firestore, Auth, and Storage.
   * Run `flutterfire configure` to generate your own `firebase_options.dart` file. 
   * *Note: The `firebase_options.dart` and `google-services.json` files are ignored in this repository for security purposes.*

5. Run the app:
   ```bash
   flutter run
   ```

## 👨‍💻 Author
Built by **Manjeet** - [GitHub Profile](https://github.com/manjeetdeswal)

:

