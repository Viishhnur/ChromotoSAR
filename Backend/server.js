const express = require('express');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const cors = require('cors');
const ort = require('onnxruntime-node');
const fs = require('fs');
const path = require('path');
const { Buffer } = require('buffer');
const sharp = require('sharp');  // For image processing

dotenv.config();

const app = express();
const port = process.env.PORT || 3001;

// Enable CORS for cross-origin requests
app.use(cors());
app.use(bodyParser.json({ limit: '50mb' }));  // Adjust payload size limit for larger images

// Load ONNX model
const modelPath = path.join(__dirname, 'modelSpecNew.onnx'); // Path to ONNX model
let session;

async function loadModel() {
  try {
    session = await ort.InferenceSession.create(modelPath);
    console.log('ONNX model loaded successfully');
  } catch (error) {
    console.error('Error loading ONNX model:', error);
  }
}
loadModel();

// Preprocess image for ONNX model
async function preprocessImage(imageBuffer) {
  try {
    const { data, info } = await sharp(imageBuffer)
      .resize(224, 224)
      .raw()
      .toBuffer({ resolveWithObject: true });

    const { width, height, channels } = info;

    if (channels !== 3) {
      throw new Error('Image must have 3 channels (RGB)');
    }

    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    const chwData = new Float32Array(width * height * channels);

    for (let c = 0; c < channels; c++) {
      for (let h = 0; h < height; h++) {
        for (let w = 0; w < width; w++) {
          const hwcIndex = h * width * channels + w * channels + c;
          const chwIndex = c * width * height + h * width + w;

          const value = data[hwcIndex] / 255.0; // Scale to [0, 1]
          chwData[chwIndex] = (value - mean[c]) / std[c]; // Apply normalization
        }
      }
    }

    const tensor = new ort.Tensor('float32', chwData, [1, 3, height, width]);

    return tensor;
  } catch (error) {
    console.error('Error preprocessing image:', error);
    throw new Error('Image preprocessing failed');
  }
}

// Run inference on the preprocessed image
async function runModel(imageTensor) {
  try {
    const feeds = { [session.inputNames[0]]: imageTensor };
    const output = await session.run(feeds);
    const outputTensor = output[session.outputNames[0]];

    const scores = outputTensor.data;
    const predictedIndex = scores.indexOf(Math.max(...scores));

    const crops = ['jute', 'maize', 'rice', 'sugarcane', 'wheat'];
    return crops[predictedIndex];
  } catch (error) {
    console.error('Error running model:', error);
    throw new Error('Model inference failed');
  }
}

// Endpoint for prediction
app.post('/predict', async (req, res) => {
  const base64Image = req.body.image;
  if (!base64Image) {
    return res.status(400).send('No image provided');
  }

  try {
    const imageBuffer = Buffer.from(base64Image, 'base64');
    console.log('Image received, processing...');

    const imageTensor = await preprocessImage(imageBuffer);
    const prediction = await runModel(imageTensor);

    res.status(200).send({ crop: prediction });
  } catch (error) {
    console.error('Error in /predict route:', error);
    res.status(500).send({ error: error.message });
  }
});

// OTP Generation and Sending Function
function generateOTP() {
  const characters = '0123456789';
  let result = '';
  for (let i = 0; i < 6; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}

// Simulated sendSMS function
async function sendSMS(mobile, from, text) {
  // Simulate SMS sending
  console.log(`Sending SMS to ${mobile} from ${from}: ${text}`);
  return Promise.resolve();
}

// Endpoint for OTP
app.post('/send-otp', async (req, res) => {
  const mobile = req.body.mobile;
  const otp = generateOTP();

  const from = 'Remote Sensing';
  const text = `Welcome to ChromotoSAR! Your OTP is ${otp}. Use it within 3 minutes to complete your registration.`;

  try {
    await sendSMS(mobile, from, text);
    res.send(`OTP: ${otp} sent to mobile number: ${mobile}`);
    console.log(`OTP sent to mobile number: ${mobile}`);
  } catch (err) {
    console.error('Failed to send OTP:', err);
    res.status(500).send('Failed to send OTP');
  }
});

// Root endpoint for server check
app.get('/', (req, res) => {
  res.send('Hello, World! The server is running.');
});

// Start server
app.listen(port, '0.0.0.0', () => {
  console.log(`Server running on http://${process.env.SERVER_IP}:${port}`);
});
