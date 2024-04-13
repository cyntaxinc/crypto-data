const express = require('express');
const fs = require('fs');
const axios = require('axios');
const cors = require('cors');
const cron = require('node-cron');
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 6000;
const APIKEY = process.env.API_KEY;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get("/", (req, res) => {
  res.json({ error : "Access Denied" });
});

app.get('/marquee', (req, res) => {
  fs.readFile("marquee.json", (err, data) => {
    if (err) {
      console.error("Error reading file:", err);
      return res.status(500).json({ error: "Internal Server Error" });
    }
    
    try {
      const info = JSON.parse(data);
      const keyMapping = {
        active_cryptocurrencies: 'active_cryptocurrencies',
        total_cryptocurrencies: 'total_cryptocurrencies',
        active_exchanges: 'active_exchanges',
        total_exchanges: 'total_exchanges',
        eth_dominance: 'eth_dominance',
        btc_dominance: 'btc_dominance',
        last_updated: 'last_updated'
      };

      const new_data = {};
      for (const originalKey in keyMapping) {
        if (info.data.hasOwnProperty(originalKey)) {
          new_data[keyMapping[originalKey]] = info.data[originalKey];
        }
      }
      
      res.json(new_data);
    } catch (error) {
      console.error("Error parsing JSON:", error);
      res.status(500).json({ error: "Internal Server Error" });
    }
  });
});

// Scheduler
cron.schedule('*/30 * * * *', async () => {
  try {
    const response = await axios.get('https://pro-api.coinmarketcap.com/v1/global-metrics/quotes/latest', {
      headers: { 'X-CMC_PRO_API_KEY': APIKEY }
    });
    
    fs.writeFile('marquee.json', JSON.stringify(response.data), (err) => {
      if (err) console.error("Error writing file:", err);
      else console.log('Data written to file');
    });
  } catch (error) {
    console.error("Error fetching data:", error);
  }
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server started on port ${PORT}`);
});
