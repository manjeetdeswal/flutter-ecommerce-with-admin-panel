import * as functions from "firebase-functions";
import Razorpay from "razorpay";

// This exports the function so your Flutter app can find it!
export const createRazorpayOrder = functions.https.onCall(async (data, context) => {
  try {
    // 1. Initialize Razorpay (Replace these with your actual test keys!)
    const instance = new Razorpay({
      key_id: "rzp_test_YourPublicKeyHere", 
      key_secret: "Your_Secret_Key_Here",
    });

    // 2. Setup the order details
    const options = {
      // Amount must be in the smallest currency unit (paise for INR)
      amount: Math.round(data.amount * 100), 
      currency: "INR", // Set to INR for India / UPI
      receipt: data.receiptId,
    };

    // 3. Ask Razorpay's servers for an official Order ID
    const order = await instance.orders.create(options);

    // 4. Send the ID securely back to your Flutter app
    return {
      orderId: order.id,
    };
    
  } catch (error) {
    console.error("Razorpay Error:", error);
    throw new functions.https.HttpsError("internal", "Unable to create Razorpay order.");
  }
});