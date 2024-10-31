const express = require('express');
const { sendSMS } = require('./otpController'); // Destructure the sendSMS function from the exported object

const app = express();
const port = 3000;

app.use(express.json()); // To parse JSON request bodies

app.post("/", (req, res) => {
  const mobile = req.body.mobile;
  const otp = generateOTP();

  // Prepare the SMS content
  const from = "Remote Sensing";
  const text = `Welcome to ChromotoSAR! Your OTP is ${otp}. Use it within 3 minutes to complete your registration.`;

  // Send OTP to the mobile number
  sendSMS(mobile, from, text)
    .then(() => {
      res.send(`OTP:-${otp} sent to mobile number: ${mobile}`);
      console.log(`OTP sent to mobile number: ${mobile}`);
    })
    .catch(err => {
      console.error('Failed to send OTP:', err);
      res.status(500).send('Failed to send OTP');
    });
});

function generateOTP(){
  const characters = '0123456789';
  let result = '';
  for (let i = 0; i < 6; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
